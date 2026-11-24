using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace BloomSpace
{
    public class OrderLine
    {
        public int FlowerId { get; set; }
        public int? BouquetNo { get; set; }
        public string FlowerName { get; set; }
        public decimal UnitPrice { get; set; }
        public int Quantity { get; set; }
        public string WrappingName { get; set; }
        public decimal WrappingPrice { get; set; }
        public string RibbonName { get; set; }
        public decimal RibbonPrice { get; set; }
        public decimal LineTotal { get; set; }
    }

    public class OrderInfo
    {
        public OrderInfo() { Lines = new List<OrderLine>(); }

        public int OrderId { get; set; }
        public string CustomerName { get; set; }
        public string Phone { get; set; }
        public string DeliveryAddress { get; set; }
        public DateTime DeliveryDate { get; set; }
        public decimal Subtotal { get; set; }
        public decimal DeliveryFee { get; set; }
        public decimal TotalAmount { get; set; }
        public string Status { get; set; }
        public DateTime OrderedAt { get; set; }
        public List<OrderLine> Lines { get; private set; }
    }

    /// <summary>Creates and reads orders.</summary>
    public static class OrderService
    {
        /// <summary>
        /// Turns the user's cart into an order inside ONE SQL transaction:
        ///   1. re-read the cart and recalculate all prices from the database,
        ///   2. insert the Orders row,
        ///   3. insert one OrderDetails row per cart row (price snapshots),
        ///   4. empty the cart.
        /// If anything fails, everything is rolled back. Returns the new OrderId, or 0 with a friendly error.
        /// </summary>
        public static int PlaceOrder(int userId, string customerName, string phone, string address, DateTime deliveryDate, out string error)
        {
            error = null;

            using (SqlConnection con = Db.Open())
            using (SqlTransaction tx = con.BeginTransaction())
            {
                try
                {
                    // 1. Refuse the order if anything in the cart was withdrawn from sale.
                    const string availSql = @"
SELECT COUNT(*) FROM dbo.Cart c
INNER JOIN dbo.Flowers f ON f.FlowerId = c.FlowerId
LEFT JOIN dbo.WrappingSheets w ON w.WrappingId = c.WrappingId
LEFT JOIN dbo.Ribbons r ON r.RibbonId = c.RibbonId
WHERE c.UserId = @u AND (f.IsActive = 0 OR w.IsActive = 0 OR r.IsActive = 0);";
                    using (SqlCommand chk = new SqlCommand(availSql, con, tx))
                    {
                        chk.Parameters.AddWithValue("@u", userId);
                        if (Convert.ToInt32(chk.ExecuteScalar()) > 0)
                        {
                            tx.Rollback();
                            error = "Some items in your cart are no longer available. Please review your cart and try again.";
                            return 0;
                        }
                    }

                    // 2. Server-side price calculation (the browser's numbers are never used).
                    CartSummary cart = CartService.Load(con, tx, userId);
                    if (cart.IsEmpty)
                    {
                        tx.Rollback();
                        error = "Your cart is empty.";
                        return 0;
                    }

                    // 3. Orders row.
                    const string orderSql = @"
INSERT INTO dbo.Orders (UserId, CustomerName, Phone, DeliveryAddress, DeliveryDate, Subtotal, DeliveryFee, TotalAmount, Status)
OUTPUT INSERTED.OrderId
VALUES (@u, @name, @phone, @addr, @date, @sub, @fee, @total, N'Placed');";

                    int orderId;
                    using (SqlCommand cmd = new SqlCommand(orderSql, con, tx))
                    {
                        cmd.Parameters.AddWithValue("@u", userId);
                        cmd.Parameters.AddWithValue("@name", customerName);
                        cmd.Parameters.AddWithValue("@phone", phone);
                        cmd.Parameters.AddWithValue("@addr", address);
                        cmd.Parameters.AddWithValue("@date", deliveryDate.Date);
                        AddMoney(cmd, "@sub", cart.Subtotal);
                        AddMoney(cmd, "@fee", cart.DeliveryFee);
                        AddMoney(cmd, "@total", cart.Total);
                        orderId = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    // 4. OrderDetails rows (snapshots of name and price).
                    const string detailSql = @"
INSERT INTO dbo.OrderDetails (OrderId, FlowerId, BouquetNo, FlowerName, UnitPrice, Quantity,
                              WrappingName, WrappingPrice, RibbonName, RibbonPrice, LineTotal)
VALUES (@o, @f, @bn, @fname, @price, @qty, @wname, @wprice, @rname, @rprice, @line);";

                    int bouquetNo = 0;
                    decimal detailSum = 0m;
                    foreach (CartGroup g in cart.Groups)
                    {
                        if (g.IsBouquet) bouquetNo++;

                        for (int i = 0; i < g.Items.Count; i++)
                        {
                            CartItem item = g.Items[i];

                            // Wrapping and ribbon are charged once per bouquet -> only on its first row.
                            decimal wPrice = (g.IsBouquet && i == 0) ? g.WrappingPrice : 0m;
                            decimal rPrice = (g.IsBouquet && i == 0) ? g.RibbonPrice : 0m;
                            decimal line = item.UnitPrice * item.Quantity + wPrice + rPrice;
                            detailSum += line;

                            using (SqlCommand cmd = new SqlCommand(detailSql, con, tx))
                            {
                                cmd.Parameters.AddWithValue("@o", orderId);
                                cmd.Parameters.AddWithValue("@f", item.FlowerId);
                                cmd.Parameters.AddWithValue("@bn", g.IsBouquet ? (object)bouquetNo : DBNull.Value);
                                cmd.Parameters.AddWithValue("@fname", item.FlowerName);
                                AddMoney(cmd, "@price", item.UnitPrice);
                                cmd.Parameters.AddWithValue("@qty", item.Quantity);
                                cmd.Parameters.AddWithValue("@wname", g.IsBouquet ? (object)g.WrappingName : DBNull.Value);
                                AddMoney(cmd, "@wprice", wPrice);
                                cmd.Parameters.AddWithValue("@rname", g.IsBouquet ? (object)g.RibbonName : DBNull.Value);
                                AddMoney(cmd, "@rprice", rPrice);
                                AddMoney(cmd, "@line", line);
                                cmd.ExecuteNonQuery();
                            }
                        }
                    }

                    // Safety net: the saved details must add up to the saved subtotal.
                    if (detailSum != cart.Subtotal)
                    {
                        throw new InvalidOperationException("Order detail total does not match the subtotal.");
                    }

                    // 5. Empty the cart.
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM dbo.Cart WHERE UserId = @u", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@u", userId);
                        cmd.ExecuteNonQuery();
                    }

                    tx.Commit();
                    return orderId;
                }
                catch (Exception ex)
                {
                    try { tx.Rollback(); } catch (Exception) { /* already rolled back */ }
                    ErrorLog.Write(ex);
                    error = "We could not place your order right now. Please try again in a moment.";
                    return 0;
                }
            }
        }

        /// <summary>Adds a money value as DECIMAL(10,2) so ADO.NET never guesses the precision.</summary>
        private static void AddMoney(SqlCommand cmd, string name, decimal value)
        {
            SqlParameter p = new SqlParameter(name, SqlDbType.Decimal);
            p.Precision = 10;
            p.Scale = 2;
            p.Value = value;
            cmd.Parameters.Add(p);
        }

        /// <summary>Loads an order. Returns null if it does not exist OR belongs to another user.</summary>
        public static OrderInfo GetOrder(int orderId, int userId)
        {
            DataTable head = Db.Table(
                @"SELECT OrderId, CustomerName, Phone, DeliveryAddress, DeliveryDate, Subtotal, DeliveryFee, TotalAmount, Status, OrderedAt
                  FROM dbo.Orders WHERE OrderId = @o AND UserId = @u",
                Db.P("@o", orderId), Db.P("@u", userId));
            if (head.Rows.Count == 0) return null;

            DataRow h = head.Rows[0];
            OrderInfo info = new OrderInfo();
            info.OrderId = (int)h["OrderId"];
            info.CustomerName = (string)h["CustomerName"];
            info.Phone = (string)h["Phone"];
            info.DeliveryAddress = (string)h["DeliveryAddress"];
            info.DeliveryDate = (DateTime)h["DeliveryDate"];
            info.Subtotal = (decimal)h["Subtotal"];
            info.DeliveryFee = (decimal)h["DeliveryFee"];
            info.TotalAmount = (decimal)h["TotalAmount"];
            info.Status = (string)h["Status"];
            info.OrderedAt = (DateTime)h["OrderedAt"];

            DataTable lines = Db.Table(
                @"SELECT FlowerId, BouquetNo, FlowerName, UnitPrice, Quantity, WrappingName, WrappingPrice, RibbonName, RibbonPrice, LineTotal
                  FROM dbo.OrderDetails WHERE OrderId = @o ORDER BY OrderDetailId",
                Db.P("@o", orderId));
            foreach (DataRow r in lines.Rows)
            {
                OrderLine l = new OrderLine();
                l.FlowerId = (int)r["FlowerId"];
                l.BouquetNo = r.IsNull("BouquetNo") ? (int?)null : (int)r["BouquetNo"];
                l.FlowerName = (string)r["FlowerName"];
                l.UnitPrice = (decimal)r["UnitPrice"];
                l.Quantity = (int)r["Quantity"];
                l.WrappingName = r.IsNull("WrappingName") ? "" : (string)r["WrappingName"];
                l.WrappingPrice = (decimal)r["WrappingPrice"];
                l.RibbonName = r.IsNull("RibbonName") ? "" : (string)r["RibbonName"];
                l.RibbonPrice = (decimal)r["RibbonPrice"];
                l.LineTotal = (decimal)r["LineTotal"];
                info.Lines.Add(l);
            }
            return info;
        }

        /// <summary>Loads all orders placed by the user, newest first, including all line items.</summary>
        public static List<OrderInfo> GetOrdersForUser(int userId)
        {
            DataTable head = Db.Table(
                @"SELECT OrderId, CustomerName, Phone, DeliveryAddress, DeliveryDate, Subtotal, DeliveryFee, TotalAmount, Status, OrderedAt
                  FROM dbo.Orders WHERE UserId = @u ORDER BY OrderId DESC",
                Db.P("@u", userId));

            List<OrderInfo> list = new List<OrderInfo>();
            if (head.Rows.Count == 0) return list;

            DataTable lines = Db.Table(
                @"SELECT od.OrderId, od.FlowerId, od.BouquetNo, od.FlowerName, od.UnitPrice, od.Quantity,
                         od.WrappingName, od.WrappingPrice, od.RibbonName, od.RibbonPrice, od.LineTotal
                  FROM dbo.OrderDetails od
                  INNER JOIN dbo.Orders o ON o.OrderId = od.OrderId
                  WHERE o.UserId = @u
                  ORDER BY od.OrderId DESC, od.OrderDetailId",
                Db.P("@u", userId));

            Dictionary<int, List<OrderLine>> lineMap = new Dictionary<int, List<OrderLine>>();
            foreach (DataRow r in lines.Rows)
            {
                int oId = (int)r["OrderId"];
                if (!lineMap.ContainsKey(oId)) lineMap[oId] = new List<OrderLine>();

                OrderLine l = new OrderLine();
                l.FlowerId = (int)r["FlowerId"];
                l.BouquetNo = r.IsNull("BouquetNo") ? (int?)null : (int)r["BouquetNo"];
                l.FlowerName = (string)r["FlowerName"];
                l.UnitPrice = (decimal)r["UnitPrice"];
                l.Quantity = (int)r["Quantity"];
                l.WrappingName = r.IsNull("WrappingName") ? "" : (string)r["WrappingName"];
                l.WrappingPrice = (decimal)r["WrappingPrice"];
                l.RibbonName = r.IsNull("RibbonName") ? "" : (string)r["RibbonName"];
                l.RibbonPrice = (decimal)r["RibbonPrice"];
                l.LineTotal = (decimal)r["LineTotal"];
                lineMap[oId].Add(l);
            }

            foreach (DataRow h in head.Rows)
            {
                OrderInfo info = new OrderInfo();
                info.OrderId = (int)h["OrderId"];
                info.CustomerName = (string)h["CustomerName"];
                info.Phone = (string)h["Phone"];
                info.DeliveryAddress = (string)h["DeliveryAddress"];
                info.DeliveryDate = (DateTime)h["DeliveryDate"];
                info.Subtotal = (decimal)h["Subtotal"];
                info.DeliveryFee = (decimal)h["DeliveryFee"];
                info.TotalAmount = (decimal)h["TotalAmount"];
                info.Status = (string)h["Status"];
                info.OrderedAt = (DateTime)h["OrderedAt"];
                if (lineMap.ContainsKey(info.OrderId))
                {
                    info.Lines.AddRange(lineMap[info.OrderId]);
                }
                list.Add(info);
            }

            return list;
        }
    }
}
