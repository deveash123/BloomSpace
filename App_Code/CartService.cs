using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.Script.Serialization;

namespace BloomSpace
{
    /// <summary>
    /// All shopping-bag operations. Every method that touches a cart line
    /// filters by UserId, so a customer can never read or change another
    /// customer's bag by guessing an id.
    /// </summary>
    public static class CartService
    {
        private static readonly JavaScriptSerializer Json = new JavaScriptSerializer();

        /* ----------------------------- CATALOGUE ----------------------------- */

        public static List<FlowerProduct> GetShopFlowers(string category)
        {
            string sql =
                @"SELECT FlowerId, Name, Category, Description, Price, PricePerStem, ImagePath, Badge
                  FROM dbo.Flowers
                  WHERE IsActive = 1 AND ShowInShop = 1";

            DataTable table;

            if (string.IsNullOrWhiteSpace(category))
            {
                sql += " ORDER BY CASE WHEN Badge IS NOT NULL THEN 0 ELSE 1 END, FlowerId";
                table = Db.GetDataTable(sql);
            }
            else
            {
                sql += " AND Category = @Category ORDER BY FlowerId";
                table = Db.GetDataTable(sql, Db.P("@Category", category.Trim()));
            }

            return MapProducts(table);
        }

        public static List<FlowerProduct> GetFeaturedFlowers(int count)
        {
            if (count < 1) count = 4;
            if (count > 8) count = 8;

            DataTable table = Db.GetDataTable(
                @"SELECT TOP (@Count) FlowerId, Name, Category, Description, Price, PricePerStem, ImagePath, Badge
                  FROM dbo.Flowers
                  WHERE IsActive = 1 AND ShowInShop = 1
                  ORDER BY CASE WHEN Badge IS NOT NULL THEN 0 ELSE 1 END, FlowerId",
                Db.P("@Count", count));

            return MapProducts(table);
        }

        public static List<FlowerOption> GetBuilderFlowers()
        {
            DataTable table = Db.GetDataTable(
                @"SELECT FlowerId, Name, Category, Description, PricePerStem, ImagePath
                  FROM dbo.Flowers
                  WHERE IsActive = 1 AND ShowInBuilder = 1
                  ORDER BY FlowerId");

            List<FlowerOption> list = new List<FlowerOption>();

            foreach (DataRow row in table.Rows)
            {
                list.Add(new FlowerOption
                {
                    FlowerId = Convert.ToInt32(row["FlowerId"]),
                    Name = Convert.ToString(row["Name"]),
                    Category = Convert.ToString(row["Category"]),
                    Description = Convert.ToString(row["Description"]),
                    PricePerStem = Convert.ToDecimal(row["PricePerStem"]),
                    ImagePath = Convert.ToString(row["ImagePath"])
                });
            }

            return list;
        }

        public static List<WrappingOption> GetWrappingOptions()
        {
            DataTable table = Db.GetDataTable(
                @"SELECT WrappingId, Name, Description, Price, ImagePath
                  FROM dbo.WrappingSheets
                  WHERE IsActive = 1
                  ORDER BY WrappingId");

            List<WrappingOption> list = new List<WrappingOption>();

            foreach (DataRow row in table.Rows)
            {
                list.Add(new WrappingOption
                {
                    WrappingId = Convert.ToInt32(row["WrappingId"]),
                    Name = Convert.ToString(row["Name"]),
                    Description = Convert.ToString(row["Description"]),
                    Price = Convert.ToDecimal(row["Price"]),
                    ImagePath = Convert.ToString(row["ImagePath"])
                });
            }

            return list;
        }

        public static List<RibbonOption> GetRibbonOptions()
        {
            DataTable table = Db.GetDataTable(
                @"SELECT RibbonId, Name, Description, Price, ColorHex
                  FROM dbo.Ribbons
                  WHERE IsActive = 1
                  ORDER BY RibbonId");

            List<RibbonOption> list = new List<RibbonOption>();

            foreach (DataRow row in table.Rows)
            {
                list.Add(new RibbonOption
                {
                    RibbonId = Convert.ToInt32(row["RibbonId"]),
                    Name = Convert.ToString(row["Name"]),
                    Description = Convert.ToString(row["Description"]),
                    Price = Convert.ToDecimal(row["Price"]),
                    ColorHex = Convert.ToString(row["ColorHex"])
                });
            }

            return list;
        }

        /* ------------------------------- CART -------------------------------- */

        public static int GetCartCount(int userId)
        {
            if (userId <= 0)
            {
                return 0;
            }

            object result = Db.ExecuteScalar(
                "SELECT ISNULL(SUM(Quantity), 0) FROM dbo.Cart WHERE UserId = @UserId",
                Db.P("@UserId", userId));

            return Convert.ToInt32(result);
        }

        public static void AddFlower(int userId, int flowerId, int quantity)
        {
            if (userId <= 0)
            {
                throw new InvalidOperationException("Please sign in to add flowers to your bag.");
            }

            if (quantity < 1 || quantity > 99)
            {
                throw new ArgumentException("Quantity must be between 1 and 99.");
            }

            DataTable flower = Db.GetDataTable(
                "SELECT FlowerId FROM dbo.Flowers WHERE FlowerId = @FlowerId AND IsActive = 1 AND ShowInShop = 1",
                Db.P("@FlowerId", flowerId));

            if (flower.Rows.Count == 0)
            {
                throw new InvalidOperationException("This bouquet is no longer available.");
            }

            int updated = Db.ExecuteNonQuery(
                @"UPDATE dbo.Cart
                  SET Quantity = CASE WHEN Quantity + @Quantity > 99 THEN 99 ELSE Quantity + @Quantity END
                  WHERE UserId = @UserId AND IsCustom = 0 AND FlowerId = @FlowerId",
                Db.P("@Quantity", quantity),
                Db.P("@UserId", userId),
                Db.P("@FlowerId", flowerId));

            if (updated == 0)
            {
                Db.ExecuteNonQuery(
                    @"INSERT INTO dbo.Cart (UserId, FlowerId, Quantity, IsCustom)
                      VALUES (@UserId, @FlowerId, @Quantity, 0)",
                    Db.P("@UserId", userId),
                    Db.P("@FlowerId", flowerId),
                    Db.P("@Quantity", quantity));
            }
        }

        public static void AddCustomBouquet(
            int userId,
            IList<CustomFlowerSelection> selections,
            int wrappingId,
            int ribbonId)
        {
            if (userId <= 0)
            {
                throw new InvalidOperationException("Please sign in to add your bouquet to the bag.");
            }

            List<CustomFlowerSelection> clean = NormalizeSelections(selections);

            DataTable wrapping = Db.GetDataTable(
                "SELECT WrappingId FROM dbo.WrappingSheets WHERE WrappingId = @Id AND IsActive = 1",
                Db.P("@Id", wrappingId));

            if (wrapping.Rows.Count == 0)
            {
                throw new ArgumentException("Please choose an available wrapping paper.");
            }

            DataTable ribbon = Db.GetDataTable(
                "SELECT RibbonId FROM dbo.Ribbons WHERE RibbonId = @Id AND IsActive = 1",
                Db.P("@Id", ribbonId));

            if (ribbon.Rows.Count == 0)
            {
                throw new ArgumentException("Please choose an available ribbon.");
            }

            foreach (CustomFlowerSelection selection in clean)
            {
                DataTable flower = Db.GetDataTable(
                    "SELECT FlowerId FROM dbo.Flowers WHERE FlowerId = @Id AND IsActive = 1 AND ShowInBuilder = 1",
                    Db.P("@Id", selection.FlowerId));

                if (flower.Rows.Count == 0)
                {
                    throw new InvalidOperationException("One of the selected flowers is no longer available.");
                }
            }

            string customData = Json.Serialize(clean);

            int updated = Db.ExecuteNonQuery(
                @"UPDATE dbo.Cart
                  SET Quantity = CASE WHEN Quantity >= 99 THEN 99 ELSE Quantity + 1 END
                  WHERE UserId = @UserId
                    AND IsCustom = 1
                    AND WrappingId = @WrappingId
                    AND RibbonId = @RibbonId
                    AND CustomData = @CustomData",
                Db.P("@UserId", userId),
                Db.P("@WrappingId", wrappingId),
                Db.P("@RibbonId", ribbonId),
                Db.P("@CustomData", customData));

            if (updated == 0)
            {
                Db.ExecuteNonQuery(
                    @"INSERT INTO dbo.Cart (UserId, Quantity, WrappingId, RibbonId, IsCustom, CustomData)
                      VALUES (@UserId, 1, @WrappingId, @RibbonId, 1, @CustomData)",
                    Db.P("@UserId", userId),
                    Db.P("@WrappingId", wrappingId),
                    Db.P("@RibbonId", ribbonId),
                    Db.P("@CustomData", customData));
            }
        }

        public static void UpdateQuantity(int userId, int cartId, int quantity)
        {
            if (quantity < 1 || quantity > 99)
            {
                throw new ArgumentException("Quantity must be between 1 and 99.");
            }

            int updated = Db.ExecuteNonQuery(
                "UPDATE dbo.Cart SET Quantity = @Quantity WHERE CartId = @CartId AND UserId = @UserId",
                Db.P("@Quantity", quantity),
                Db.P("@CartId", cartId),
                Db.P("@UserId", userId));

            if (updated == 0)
            {
                throw new InvalidOperationException("That bag item could not be found.");
            }
        }

        public static void RemoveLine(int userId, int cartId)
        {
            int deleted = Db.ExecuteNonQuery(
                "DELETE FROM dbo.Cart WHERE CartId = @CartId AND UserId = @UserId",
                Db.P("@CartId", cartId),
                Db.P("@UserId", userId));

            if (deleted == 0)
            {
                throw new InvalidOperationException("That bag item could not be found.");
            }
        }

        public static CartSummary GetCart(int userId)
        {
            CartSummary summary = new CartSummary();
            summary.Lines = GetCartLines(userId);

            decimal subtotal = 0m;
            int itemCount = 0;

            foreach (CartLine line in summary.Lines)
            {
                if (line.IsValid)
                {
                    subtotal += line.LineTotal;
                    itemCount += line.Quantity;
                }
            }

            summary.Subtotal = subtotal;
            summary.DeliveryFee = Pricing.GetDeliveryFee(subtotal);
            summary.GrandTotal = subtotal + summary.DeliveryFee;
            summary.ItemCount = itemCount;
            summary.HasFreeDelivery = subtotal >= Pricing.FreeDeliveryThreshold;
            summary.AmountToFreeDelivery = Math.Max(0m, Pricing.FreeDeliveryThreshold - subtotal);
            summary.HasInvalidLines = summary.Lines.Any(line => !line.IsValid);

            return summary;
        }

        /// <summary>
        /// Reads the bag and recalculates every line from the live catalogue.
        /// This is the only price the application trusts.
        /// </summary>
        public static List<CartLine> GetCartLines(int userId)
        {
            List<CartLine> lines = new List<CartLine>();

            if (userId <= 0)
            {
                return lines;
            }

            DataTable cart = Db.GetDataTable(
                @"SELECT c.CartId, c.FlowerId, c.Quantity, c.WrappingId, c.RibbonId, c.IsCustom, c.CustomData,
                         f.Name AS FlowerName, f.Category AS FlowerCategory, f.Price AS FlowerPrice,
                         f.ImagePath AS FlowerImage, f.IsActive AS FlowerActive,
                         w.Name AS WrappingName, w.Price AS WrappingPrice, w.IsActive AS WrappingActive,
                         r.Name AS RibbonName, r.Price AS RibbonPrice, r.IsActive AS RibbonActive
                  FROM dbo.Cart c
                  LEFT JOIN dbo.Flowers f ON f.FlowerId = c.FlowerId
                  LEFT JOIN dbo.WrappingSheets w ON w.WrappingId = c.WrappingId
                  LEFT JOIN dbo.Ribbons r ON r.RibbonId = c.RibbonId
                  WHERE c.UserId = @UserId
                  ORDER BY c.AddedAt DESC, c.CartId DESC",
                Db.P("@UserId", userId));

            if (cart.Rows.Count == 0)
            {
                return lines;
            }

            // One lookup table for every flower, used to price custom bouquets.
            DataTable flowerTable = Db.GetDataTable(
                "SELECT FlowerId, Name, PricePerStem, IsActive FROM dbo.Flowers");

            Dictionary<int, DataRow> flowers = new Dictionary<int, DataRow>();

            foreach (DataRow row in flowerTable.Rows)
            {
                flowers[Convert.ToInt32(row["FlowerId"])] = row;
            }

            foreach (DataRow row in cart.Rows)
            {
                CartLine line = new CartLine
                {
                    CartId = Convert.ToInt32(row["CartId"]),
                    IsCustom = Convert.ToBoolean(row["IsCustom"]),
                    Quantity = Convert.ToInt32(row["Quantity"]),
                    CustomFlowers = new List<CustomFlowerSelection>(),
                    IsValid = true,
                    ValidationMessage = string.Empty
                };

                if (!line.IsCustom)
                {
                    BuildSimpleLine(line, row);
                }
                else
                {
                    BuildCustomLine(line, row, flowers);
                }

                if (!line.IsValid)
                {
                    line.LineTotal = 0m;
                }

                lines.Add(line);
            }

            return lines;
        }

        /* ----------------------------- INTERNALS ----------------------------- */

        private static void BuildSimpleLine(CartLine line, DataRow row)
        {
            bool active =
                row["FlowerName"] != DBNull.Value &&
                row["FlowerActive"] != DBNull.Value &&
                Convert.ToBoolean(row["FlowerActive"]);

            line.FlowerId = row["FlowerId"] == DBNull.Value
                ? (int?)null
                : Convert.ToInt32(row["FlowerId"]);

            if (!active)
            {
                line.Title = "Unavailable bouquet";
                line.Description = "This bouquet has been removed from the collection.";
                line.ImagePath = "~/Images/Flowers/rose.svg";
                line.UnitPrice = 0m;
                line.FlowerCost = 0m;
                line.WrappingName = "Signature Wrap";
                line.WrappingPrice = 0m;
                line.RibbonName = "Blush Satin Ribbon";
                line.RibbonPrice = 0m;
                line.IsValid = false;
                line.ValidationMessage = "Remove this item to continue to checkout.";
                line.LineTotal = 0m;
                return;
            }

            line.Title = Convert.ToString(row["FlowerName"]);
            line.Description = Convert.ToString(row["FlowerCategory"]) + " \u00B7 ready-made bouquet";
            line.ImagePath = row["FlowerImage"] == DBNull.Value
                ? "~/Images/Flowers/rose.svg"
                : Convert.ToString(row["FlowerImage"]);
            line.UnitPrice = Convert.ToDecimal(row["FlowerPrice"]);
            line.FlowerCost = line.UnitPrice;

            // Ready-made bouquets arrive gift-wrapped; the price is included.
            line.WrappingName = "Signature Wrap";
            line.WrappingPrice = 0m;
            line.RibbonName = "Blush Satin Ribbon";
            line.RibbonPrice = 0m;

            line.LineTotal = line.UnitPrice * line.Quantity;
        }

        private static void BuildCustomLine(
            CartLine line,
            DataRow row,
            Dictionary<int, DataRow> flowers)
        {
            line.Title = "Custom Bouquet";
            line.ImagePath = "~/Images/Flowers/custom-bouquet.svg";
            line.WrappingName = row["WrappingName"] == DBNull.Value
                ? null
                : Convert.ToString(row["WrappingName"]);
            line.WrappingPrice = row["WrappingPrice"] == DBNull.Value
                ? 0m
                : Convert.ToDecimal(row["WrappingPrice"]);
            line.RibbonName = row["RibbonName"] == DBNull.Value
                ? null
                : Convert.ToString(row["RibbonName"]);
            line.RibbonPrice = row["RibbonPrice"] == DBNull.Value
                ? 0m
                : Convert.ToDecimal(row["RibbonPrice"]);

            bool valid = true;

            if (row["WrappingName"] == DBNull.Value ||
                row["WrappingActive"] == DBNull.Value ||
                !Convert.ToBoolean(row["WrappingActive"]))
            {
                valid = false;
            }

            if (row["RibbonName"] == DBNull.Value ||
                row["RibbonActive"] == DBNull.Value ||
                !Convert.ToBoolean(row["RibbonActive"]))
            {
                valid = false;
            }

            List<CustomFlowerSelection> selections = null;

            try
            {
                string json = Convert.ToString(row["CustomData"]);

                if (!string.IsNullOrWhiteSpace(json))
                {
                    selections = Json.Deserialize<List<CustomFlowerSelection>>(json);
                }
            }
            catch
            {
                selections = null;
            }

            if (selections == null || selections.Count == 0)
            {
                valid = false;
                selections = new List<CustomFlowerSelection>();
            }

            decimal flowerCost = 0m;
            int stems = 0;
            List<string> parts = new List<string>();

            foreach (CustomFlowerSelection selection in selections)
            {
                DataRow flowerRow;

                if (selection.Quantity <= 0 ||
                    !flowers.TryGetValue(selection.FlowerId, out flowerRow) ||
                    flowerRow["IsActive"] == DBNull.Value ||
                    !Convert.ToBoolean(flowerRow["IsActive"]))
                {
                    valid = false;
                    continue;
                }

                decimal stemPrice = Convert.ToDecimal(flowerRow["PricePerStem"]);
                flowerCost += stemPrice * selection.Quantity;
                stems += selection.Quantity;

                parts.Add(selection.Quantity + " \u00D7 " + Convert.ToString(flowerRow["Name"]));
            }

            line.CustomFlowers = selections;
            line.StemCount = stems;
            line.FlowerCost = flowerCost;
            line.UnitPrice = flowerCost + line.WrappingPrice + line.RibbonPrice;
            line.Description = parts.Count > 0
                ? string.Join(", ", parts)
                : "Custom arrangement";

            if (stems <= 0)
            {
                valid = false;
            }

            line.IsValid = valid;
            line.ValidationMessage = valid
                ? string.Empty
                : "Some options in this bouquet are no longer available. Please remove it and build again.";

            line.LineTotal = line.UnitPrice * line.Quantity;
        }

        private static List<CustomFlowerSelection> NormalizeSelections(
            IList<CustomFlowerSelection> input)
        {
            if (input == null)
            {
                throw new ArgumentException("Please choose at least one flower.");
            }

            Dictionary<int, int> merged = new Dictionary<int, int>();
            int totalStems = 0;

            foreach (CustomFlowerSelection item in input)
            {
                if (item == null || item.FlowerId <= 0 || item.Quantity <= 0)
                {
                    continue;
                }

                if (item.Quantity > Pricing.MaxStemsPerFlowerType)
                {
                    throw new ArgumentException(
                        "You can choose up to " + Pricing.MaxStemsPerFlowerType + " stems of one flower.");
                }

                int current;

                if (merged.TryGetValue(item.FlowerId, out current))
                {
                    merged[item.FlowerId] = current + item.Quantity;
                }
                else
                {
                    merged[item.FlowerId] = item.Quantity;
                }

                totalStems += item.Quantity;
            }

            if (merged.Count == 0)
            {
                throw new ArgumentException("Please choose at least one flower.");
            }

            if (totalStems > Pricing.MaxStemsPerBouquet)
            {
                throw new ArgumentException(
                    "A bouquet can hold up to " + Pricing.MaxStemsPerBouquet + " stems.");
            }

            List<CustomFlowerSelection> result = new List<CustomFlowerSelection>();

            foreach (KeyValuePair<int, int> pair in merged.OrderBy(p => p.Key))
            {
                result.Add(new CustomFlowerSelection
                {
                    FlowerId = pair.Key,
                    Quantity = pair.Value
                });
            }

            return result;
        }

        private static List<FlowerProduct> MapProducts(DataTable table)
        {
            List<FlowerProduct> list = new List<FlowerProduct>();

            foreach (DataRow row in table.Rows)
            {
                list.Add(new FlowerProduct
                {
                    FlowerId = Convert.ToInt32(row["FlowerId"]),
                    Name = Convert.ToString(row["Name"]),
                    Category = Convert.ToString(row["Category"]),
                    Description = Convert.ToString(row["Description"]),
                    Price = Convert.ToDecimal(row["Price"]),
                    PricePerStem = Convert.ToDecimal(row["PricePerStem"]),
                    ImagePath = Convert.ToString(row["ImagePath"]),
                    Badge = row["Badge"] == DBNull.Value ? null : Convert.ToString(row["Badge"])
                });
            }

            return list;
        }
    }
}
