using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace BloomSpace
{
    /// <summary>One flower row in the cart (prices come live from the Flowers table).</summary>
    public class CartItem
    {
        public int CartId { get; set; }
        public int FlowerId { get; set; }
        public string FlowerName { get; set; }
        public string ImageUrl { get; set; }
        public decimal UnitPrice { get; set; }
        public int Quantity { get; set; }
        public decimal LineTotal { get { return UnitPrice * Quantity; } }
    }

    /// <summary>
    /// Either the "Individual Flowers" group (single stems) or one custom bouquet.
    /// Wrapping and ribbon are charged once per bouquet.
    /// </summary>
    public class CartGroup
    {
        public CartGroup() { Items = new List<CartItem>(); }

        public bool IsBouquet { get; set; }
        public Guid BouquetId { get; set; }
        public List<CartItem> Items { get; private set; }

        public int WrappingId { get; set; }
        public string WrappingName { get; set; }
        public decimal WrappingPrice { get; set; }
        public int RibbonId { get; set; }
        public string RibbonName { get; set; }
        public decimal RibbonPrice { get; set; }

        public decimal FlowerTotal
        {
            get
            {
                decimal sum = 0m;
                foreach (CartItem i in Items) sum += i.LineTotal;
                return sum;
            }
        }

        /// <summary>Flower Cost + Wrapping + Ribbon (wrapping/ribbon only exist on bouquets).</summary>
        public decimal GroupTotal
        {
            get { return FlowerTotal + (IsBouquet ? WrappingPrice + RibbonPrice : 0m); }
        }
    }

    public class CartSummary
    {
        public CartSummary() { Groups = new List<CartGroup>(); }

        public List<CartGroup> Groups { get; private set; }
        public decimal Subtotal { get; set; }
        public decimal DeliveryFee { get; set; }
        public decimal Total { get; set; }
        public bool IsEmpty { get { return Groups.Count == 0; } }
    }

    /// <summary>All cart database work. Every method filters by UserId, so users can only touch their own cart.</summary>
    public static class CartService
    {
        public const int MaxQty = 50;

        // ---------------------------------------------------------------- reading

        public static CartSummary Load(int userId)
        {
            using (SqlConnection con = Db.Open())
            {
                return Load(con, null, userId);
            }
        }

        /// <summary>
        /// Reads the cart and recalculates every price from the catalogue tables.
        /// Also used inside the checkout transaction so the order total is always server-calculated.
        /// </summary>
        public static CartSummary Load(SqlConnection con, SqlTransaction tx, int userId)
        {
            const string sql = @"
SELECT c.CartId, c.FlowerId, f.Name, f.ImageUrl, f.UnitPrice, c.Quantity,
       c.BouquetId, c.WrappingId, w.Name, w.Price, c.RibbonId, r.Name, r.Price
FROM dbo.Cart c
INNER JOIN dbo.Flowers f ON f.FlowerId = c.FlowerId
LEFT JOIN dbo.WrappingSheets w ON w.WrappingId = c.WrappingId
LEFT JOIN dbo.Ribbons r ON r.RibbonId = c.RibbonId
WHERE c.UserId = @uid
ORDER BY c.AddedAt, c.CartId;";

            CartSummary summary = new CartSummary();
            Dictionary<Guid, CartGroup> bouquets = new Dictionary<Guid, CartGroup>();
            CartGroup singles = null;

            using (SqlCommand cmd = new SqlCommand(sql, con, tx))
            {
                cmd.Parameters.AddWithValue("@uid", userId);
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        CartItem item = new CartItem();
                        item.CartId = r.GetInt32(0);
                        item.FlowerId = r.GetInt32(1);
                        item.FlowerName = r.GetString(2);
                        item.ImageUrl = r.GetString(3);
                        item.UnitPrice = r.GetDecimal(4);
                        item.Quantity = r.GetInt32(5);

                        if (r.IsDBNull(6))
                        {
                            if (singles == null)
                            {
                                singles = new CartGroup();
                                singles.IsBouquet = false;
                                summary.Groups.Add(singles);
                            }
                            singles.Items.Add(item);
                        }
                        else
                        {
                            Guid bid = r.GetGuid(6);
                            CartGroup g;
                            if (!bouquets.TryGetValue(bid, out g))
                            {
                                g = new CartGroup();
                                g.IsBouquet = true;
                                g.BouquetId = bid;
                                g.WrappingId = r.IsDBNull(7) ? 0 : r.GetInt32(7);
                                g.WrappingName = r.IsDBNull(8) ? "" : r.GetString(8);
                                g.WrappingPrice = r.IsDBNull(9) ? 0m : r.GetDecimal(9);
                                g.RibbonId = r.IsDBNull(10) ? 0 : r.GetInt32(10);
                                g.RibbonName = r.IsDBNull(11) ? "" : r.GetString(11);
                                g.RibbonPrice = r.IsDBNull(12) ? 0m : r.GetDecimal(12);
                                bouquets.Add(bid, g);
                                summary.Groups.Add(g);
                            }
                            g.Items.Add(item);
                        }
                    }
                }
            }

            decimal subtotal = 0m;
            foreach (CartGroup g in summary.Groups) subtotal += g.GroupTotal;
            summary.Subtotal = subtotal;
            summary.DeliveryFee = summary.Groups.Count > 0 ? Db.DeliveryFee : 0m;
            summary.Total = summary.Subtotal + summary.DeliveryFee;
            return summary;
        }

        /// <summary>Total number of stems in the cart (shown in the header badge).</summary>
        public static int StemCount(int userId)
        {
            object v = Db.Scalar("SELECT ISNULL(SUM(Quantity), 0) FROM dbo.Cart WHERE UserId = @u", Db.P("@u", userId));
            return Convert.ToInt32(v);
        }

        // ---------------------------------------------------------------- adding

        /// <summary>Adds one flower type from the Shop. Returns false if the flower does not exist or is inactive.</summary>
        public static bool AddSingle(int userId, int flowerId, int quantity)
        {
            if (quantity < 1 || quantity > MaxQty) return false;

            using (SqlConnection con = Db.Open())
            {
                if (!FlowerIsActive(con, null, flowerId)) return false;

                const string sql = @"
UPDATE dbo.Cart
   SET Quantity = CASE WHEN Quantity + @q > @max THEN @max ELSE Quantity + @q END
 WHERE UserId = @u AND FlowerId = @f AND BouquetId IS NULL;
IF @@ROWCOUNT = 0
    INSERT INTO dbo.Cart (UserId, FlowerId, Quantity) VALUES (@u, @f, @q);";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@u", userId);
                    cmd.Parameters.AddWithValue("@f", flowerId);
                    cmd.Parameters.AddWithValue("@q", quantity);
                    cmd.Parameters.AddWithValue("@max", MaxQty);
                    cmd.ExecuteNonQuery();
                }
            }
            return true;
        }

        /// <summary>
        /// Saves a custom bouquet. flowers = FlowerId -> quantity. Only IDs and quantities come from the
        /// browser; the server checks every ID against the database and never accepts a price.
        /// </summary>
        public static bool AddBouquet(int userId, IDictionary<int, int> flowers, int wrappingId, int ribbonId, out string error)
        {
            error = null;

            if (flowers == null || flowers.Count == 0)
            {
                error = "Please choose at least one flower for your bouquet.";
                return false;
            }
            int stems = 0;
            foreach (KeyValuePair<int, int> kv in flowers)
            {
                if (kv.Value < 1 || kv.Value > MaxQty)
                {
                    error = "Each flower quantity must be between 1 and " + MaxQty + ".";
                    return false;
                }
                stems += kv.Value;
            }
            if (stems > 200)
            {
                error = "That is a very large bouquet! Please keep it to 200 stems or fewer.";
                return false;
            }

            using (SqlConnection con = Db.Open())
            using (SqlTransaction tx = con.BeginTransaction())
            {
                foreach (int flowerId in flowers.Keys)
                {
                    if (!FlowerIsActive(con, tx, flowerId))
                    {
                        tx.Rollback();
                        error = "One of the selected flowers is no longer available.";
                        return false;
                    }
                }
                if (!OptionIsActive(con, tx, "dbo.WrappingSheets", "WrappingId", wrappingId))
                {
                    tx.Rollback();
                    error = "Please choose a valid wrapping paper.";
                    return false;
                }
                if (!OptionIsActive(con, tx, "dbo.Ribbons", "RibbonId", ribbonId))
                {
                    tx.Rollback();
                    error = "Please choose a valid ribbon.";
                    return false;
                }

                Guid bouquetId = Guid.NewGuid();
                const string sql = @"INSERT INTO dbo.Cart (UserId, FlowerId, Quantity, BouquetId, WrappingId, RibbonId)
                                     VALUES (@u, @f, @q, @b, @w, @r);";
                foreach (KeyValuePair<int, int> kv in flowers)
                {
                    using (SqlCommand cmd = new SqlCommand(sql, con, tx))
                    {
                        cmd.Parameters.AddWithValue("@u", userId);
                        cmd.Parameters.AddWithValue("@f", kv.Key);
                        cmd.Parameters.AddWithValue("@q", kv.Value);
                        cmd.Parameters.AddWithValue("@b", bouquetId);
                        cmd.Parameters.AddWithValue("@w", wrappingId);
                        cmd.Parameters.AddWithValue("@r", ribbonId);
                        cmd.ExecuteNonQuery();
                    }
                }
                tx.Commit();
            }
            return true;
        }

        // ---------------------------------------------------------------- editing (ownership checked via UserId)

        public static bool UpdateQuantity(int userId, int cartId, int quantity)
        {
            if (quantity < 1 || quantity > MaxQty) return false;
            return Exec("UPDATE dbo.Cart SET Quantity = @q WHERE CartId = @c AND UserId = @u",
                        Db.P("@q", quantity), Db.P("@c", cartId), Db.P("@u", userId)) > 0;
        }

        public static void RemoveItem(int userId, int cartId)
        {
            Exec("DELETE FROM dbo.Cart WHERE CartId = @c AND UserId = @u", Db.P("@c", cartId), Db.P("@u", userId));
        }

        public static void RemoveBouquet(int userId, Guid bouquetId)
        {
            Exec("DELETE FROM dbo.Cart WHERE BouquetId = @b AND UserId = @u", Db.P("@b", bouquetId), Db.P("@u", userId));
        }

        /// <summary>Changes the wrapping and ribbon of a bouquet already in the cart.</summary>
        public static bool UpdateBouquetOptions(int userId, Guid bouquetId, int wrappingId, int ribbonId)
        {
            using (SqlConnection con = Db.Open())
            {
                if (!OptionIsActive(con, null, "dbo.WrappingSheets", "WrappingId", wrappingId)) return false;
                if (!OptionIsActive(con, null, "dbo.Ribbons", "RibbonId", ribbonId)) return false;

                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE dbo.Cart SET WrappingId = @w, RibbonId = @r WHERE BouquetId = @b AND UserId = @u", con))
                {
                    cmd.Parameters.AddWithValue("@w", wrappingId);
                    cmd.Parameters.AddWithValue("@r", ribbonId);
                    cmd.Parameters.AddWithValue("@b", bouquetId);
                    cmd.Parameters.AddWithValue("@u", userId);
                    cmd.ExecuteNonQuery();
                }
            }
            return true;
        }

        // ---------------------------------------------------------------- helpers

        private static int Exec(string sql, params SqlParameter[] ps)
        {
            using (SqlConnection con = Db.Open())
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddRange(ps);
                return cmd.ExecuteNonQuery();
            }
        }

        private static bool FlowerIsActive(SqlConnection con, SqlTransaction tx, int flowerId)
        {
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.Flowers WHERE FlowerId = @f AND IsActive = 1", con, tx))
            {
                cmd.Parameters.AddWithValue("@f", flowerId);
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }

        // table and column names below are fixed strings from this file (never user input).
        private static bool OptionIsActive(SqlConnection con, SqlTransaction tx, string table, string idColumn, int id)
        {
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM " + table + " WHERE " + idColumn + " = @id AND IsActive = 1", con, tx))
            {
                cmd.Parameters.AddWithValue("@id", id);
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }
    }
}
