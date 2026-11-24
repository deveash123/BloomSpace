using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace BloomSpace
{
    /// <summary>
    /// Order creation and retrieval.
    /// The order header and every order line are written inside one SQL
    /// transaction: either the whole order is saved, or nothing is.
    /// Prices are recalculated from the catalogue first and then copied into
    /// OrderDetails as historical snapshots.
    /// </summary>
    public static class OrderService
    {
        public static int PlaceOrder(
            int userId,
            string customerName,
            string phone,
            string address,
            DateTime deliveryDate,
            out string error)
        {
            error = null;

            if (userId <= 0)
            {
                error = "Please sign in to place your order.";
                return 0;
            }

            customerName = (customerName ?? string.Empty).Trim();
            phone = Validation.NormalizePhone(phone);
            address = (address ?? string.Empty).Trim();

            if (!Validation.IsValidName(customerName))
            {
                error = "Please enter your full name (letters, spaces, apostrophes or hyphens).";
                return 0;
            }

            if (!Validation.IsValidPhone(phone))
            {
                error = "Please enter a valid 10-digit Indian mobile number.";
                return 0;
            }

            if (!Validation.IsValidAddress(address))
            {
                error = "Please enter a complete delivery address (at least 10 characters).";
                return 0;
            }

            if (!Validation.IsValidDeliveryDate(deliveryDate))
            {
                error = "Please choose a delivery date between tomorrow and 30 days from today.";
                return 0;
            }

            CartSummary cart = CartService.GetCart(userId);

            if (cart.Lines.Count == 0)
            {
                error = "Your bag is empty. Add a bouquet before checking out.";
                return 0;
            }

            if (cart.HasInvalidLines)
            {
                error = "Some items in your bag are no longer available. Please remove them before checking out.";
                return 0;
            }

            if (cart.Subtotal <= 0m)
            {
                error = "Your bag is empty. Add a bouquet before checking out.";
                return 0;
            }

            using (SqlConnection connection = Db.OpenConnection())
            using (SqlTransaction transaction = connection.BeginTransaction())
            {
                try
                {
                    int orderId;

                    const string orderSql =
                        @"INSERT INTO dbo.Orders
                              (UserId, CustomerName, Phone, DeliveryAddress, DeliveryDate,
                               FlowerSubtotal, DeliveryFee, GrandTotal, Status)
                          VALUES
                              (@UserId, @CustomerName, @Phone, @DeliveryAddress, @DeliveryDate,
                               @FlowerSubtotal, @DeliveryFee, @GrandTotal, N'Confirmed');

                          SELECT CAST(SCOPE_IDENTITY() AS INT);";

                    using (SqlCommand command = new SqlCommand(orderSql, connection, transaction))
                    {
                        command.Parameters.AddWithValue("@UserId", userId);
                        command.Parameters.AddWithValue("@CustomerName", customerName);
                        command.Parameters.AddWithValue("@Phone", phone);
                        command.Parameters.AddWithValue("@DeliveryAddress", address);
                        command.Parameters.AddWithValue("@DeliveryDate", deliveryDate.Date);
                        command.Parameters.AddWithValue("@FlowerSubtotal", cart.Subtotal);
                        command.Parameters.AddWithValue("@DeliveryFee", cart.DeliveryFee);
                        command.Parameters.AddWithValue("@GrandTotal", cart.GrandTotal);

                        orderId = Convert.ToInt32(command.ExecuteScalar());
                    }

                    const string detailSql =
                        @"INSERT INTO dbo.OrderDetails
                              (OrderId, FlowerId, ItemName, Quantity, UnitPrice,
                               WrappingName, WrappingPrice, RibbonName, RibbonPrice, LineTotal)
                          VALUES
                              (@OrderId, @FlowerId, @ItemName, @Quantity, @UnitPrice,
                               @WrappingName, @WrappingPrice, @RibbonName, @RibbonPrice, @LineTotal);";

                    foreach (CartLine line in cart.Lines)
                    {
                        string itemName = line.IsCustom
                            ? "Custom Bouquet - " + line.Description
                            : line.Title;

                        if (itemName.Length > 300)
                        {
                            itemName = itemName.Substring(0, 297) + "...";
                        }

                        using (SqlCommand command = new SqlCommand(detailSql, connection, transaction))
                        {
                            command.Parameters.AddWithValue("@OrderId", orderId);
                            command.Parameters.AddWithValue(
                                "@FlowerId",
                                line.IsCustom || !line.FlowerId.HasValue
                                    ? (object)DBNull.Value
                                    : line.FlowerId.Value);
                            command.Parameters.AddWithValue("@ItemName", itemName);
                            command.Parameters.AddWithValue("@Quantity", line.Quantity);
                            command.Parameters.AddWithValue("@UnitPrice", line.FlowerCost);
                            command.Parameters.AddWithValue(
                                "@WrappingName",
                                (object)line.WrappingName ?? DBNull.Value);
                            command.Parameters.AddWithValue("@WrappingPrice", line.WrappingPrice);
                            command.Parameters.AddWithValue(
                                "@RibbonName",
                                (object)line.RibbonName ?? DBNull.Value);
                            command.Parameters.AddWithValue("@RibbonPrice", line.RibbonPrice);
                            command.Parameters.AddWithValue("@LineTotal", line.LineTotal);

                            command.ExecuteNonQuery();
                        }
                    }

                    using (SqlCommand command = new SqlCommand(
                        "DELETE FROM dbo.Cart WHERE UserId = @UserId",
                        connection,
                        transaction))
                    {
                        command.Parameters.AddWithValue("@UserId", userId);
                        command.ExecuteNonQuery();
                    }

                    transaction.Commit();
                    return orderId;
                }
                catch
                {
                    try
                    {
                        transaction.Rollback();
                    }
                    catch
                    {
                        // The original exception is more useful than a rollback failure.
                    }

                    throw;
                }
            }
        }

        /// <summary>
        /// Loads an order only when it belongs to the signed-in customer.
        /// Returns null when the order does not exist or belongs to someone else.
        /// </summary>
        public static OrderView GetOrder(int orderId, int userId)
        {
            if (orderId <= 0 || userId <= 0)
            {
                return null;
            }

            DataTable orderTable = Db.GetDataTable(
                @"SELECT OrderId, CustomerName, Phone, DeliveryAddress, DeliveryDate,
                         FlowerSubtotal, DeliveryFee, GrandTotal, Status, OrderDate
                  FROM dbo.Orders
                  WHERE OrderId = @OrderId AND UserId = @UserId",
                Db.P("@OrderId", orderId),
                Db.P("@UserId", userId));

            if (orderTable.Rows.Count == 0)
            {
                return null;
            }

            DataRow row = orderTable.Rows[0];

            OrderView order = new OrderView
            {
                OrderId = Convert.ToInt32(row["OrderId"]),
                CustomerName = Convert.ToString(row["CustomerName"]),
                Phone = Convert.ToString(row["Phone"]),
                DeliveryAddress = Convert.ToString(row["DeliveryAddress"]),
                DeliveryDate = Convert.ToDateTime(row["DeliveryDate"]),
                FlowerSubtotal = Convert.ToDecimal(row["FlowerSubtotal"]),
                DeliveryFee = Convert.ToDecimal(row["DeliveryFee"]),
                GrandTotal = Convert.ToDecimal(row["GrandTotal"]),
                Status = Convert.ToString(row["Status"]),
                OrderDate = Convert.ToDateTime(row["OrderDate"]),
                Lines = new List<OrderLine>()
            };

            DataTable detailTable = Db.GetDataTable(
                @"SELECT ItemName, Quantity, UnitPrice, WrappingName, WrappingPrice,
                         RibbonName, RibbonPrice, LineTotal
                  FROM dbo.OrderDetails
                  WHERE OrderId = @OrderId
                  ORDER BY OrderDetailId",
                Db.P("@OrderId", orderId));

            foreach (DataRow detail in detailTable.Rows)
            {
                order.Lines.Add(new OrderLine
                {
                    ItemName = Convert.ToString(detail["ItemName"]),
                    Quantity = Convert.ToInt32(detail["Quantity"]),
                    UnitPrice = Convert.ToDecimal(detail["UnitPrice"]),
                    WrappingName = detail["WrappingName"] == DBNull.Value
                        ? null
                        : Convert.ToString(detail["WrappingName"]),
                    WrappingPrice = Convert.ToDecimal(detail["WrappingPrice"]),
                    RibbonName = detail["RibbonName"] == DBNull.Value
                        ? null
                        : Convert.ToString(detail["RibbonName"]),
                    RibbonPrice = Convert.ToDecimal(detail["RibbonPrice"]),
                    LineTotal = Convert.ToDecimal(detail["LineTotal"])
                });
            }

            return order;
        }
    }
}
