using System;
using System.Collections.Generic;
using System.Globalization;

namespace BloomSpace
{
    /// <summary>Safe account fields returned after login (never the password hash).</summary>
    public class UserRecord
    {
        public int UserId { get; set; }
        public string FullName { get; set; }
        public string Email { get; set; }
        public string Phone { get; set; }
    }

    /// <summary>A ready-made bouquet shown in the Shop.</summary>
    public class FlowerProduct
    {
        public int FlowerId { get; set; }
        public string Name { get; set; }
        public string Category { get; set; }
        public string Description { get; set; }
        public decimal Price { get; set; }
        public decimal PricePerStem { get; set; }
        public string ImagePath { get; set; }
        public string Badge { get; set; }

        public string PriceText { get { return Pricing.Inr(Price); } }
        public bool HasBadge { get { return !string.IsNullOrWhiteSpace(Badge); } }
    }

    /// <summary>A per-stem flower offered in the Custom Bouquet builder.</summary>
    public class FlowerOption
    {
        public int FlowerId { get; set; }
        public string Name { get; set; }
        public string Category { get; set; }
        public string Description { get; set; }
        public decimal PricePerStem { get; set; }
        public string ImagePath { get; set; }

        public string PriceText { get { return Pricing.Inr(PricePerStem); } }

        public string PriceRaw
        {
            get { return PricePerStem.ToString("0.00", CultureInfo.InvariantCulture); }
        }
    }

    public class WrappingOption
    {
        public int WrappingId { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public decimal Price { get; set; }
        public string ImagePath { get; set; }

        public string PriceText { get { return Pricing.Inr(Price); } }

        public string PriceRaw
        {
            get { return Price.ToString("0.00", CultureInfo.InvariantCulture); }
        }

        /// <summary>Used by the live bouquet preview to tint the paper wrap.</summary>
        public string PreviewColor
        {
            get
            {
                string name = (Name ?? string.Empty).ToLowerInvariant();

                if (name.Contains("pink"))
                {
                    return "#E9C6CE";
                }

                if (name.Contains("kraft") || name.Contains("brown"))
                {
                    return "#C8A27E";
                }

                return "#FFFDF8";
            }
        }

        public string PreviewKey
        {
            get
            {
                string name = (Name ?? string.Empty).ToLowerInvariant();

                if (name.Contains("pink"))
                {
                    return "pink";
                }

                if (name.Contains("kraft") || name.Contains("brown"))
                {
                    return "kraft";
                }

                return "white";
            }
        }
    }

    public class RibbonOption
    {
        public int RibbonId { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public decimal Price { get; set; }
        public string ColorHex { get; set; }

        public string PriceText { get { return Pricing.Inr(Price); } }

        public string PriceRaw
        {
            get { return Price.ToString("0.00", CultureInfo.InvariantCulture); }
        }

        /// <summary>Maps the three ribbon colours to their illustration.</summary>
        public string ImagePath
        {
            get
            {
                string name = (Name ?? string.Empty).ToLowerInvariant();

                if (name.Contains("red"))
                {
                    return "~/Images/Ribbons/classic-red.svg";
                }

                if (name.Contains("white"))
                {
                    return "~/Images/Ribbons/soft-white.svg";
                }

                return "~/Images/Ribbons/satin-pink.svg";
            }
        }
    }

    public class CustomFlowerSelection
    {
        public int FlowerId { get; set; }
        public int Quantity { get; set; }
    }

    /// <summary>One line in the shopping bag, already priced from the database.</summary>
    public class CartLine
    {
        public int CartId { get; set; }
        public bool IsCustom { get; set; }
        public int? FlowerId { get; set; }
        public int Quantity { get; set; }

        public string Title { get; set; }
        public string Description { get; set; }
        public string ImagePath { get; set; }

        /// <summary>Price charged per bouquet, including wrapping and ribbon for custom lines.</summary>
        public decimal UnitPrice { get; set; }

        /// <summary>Flower-only cost per bouquet (used for the order-detail snapshot).</summary>
        public decimal FlowerCost { get; set; }

        public string WrappingName { get; set; }
        public decimal WrappingPrice { get; set; }
        public string RibbonName { get; set; }
        public decimal RibbonPrice { get; set; }
        public decimal LineTotal { get; set; }

        public List<CustomFlowerSelection> CustomFlowers { get; set; }
        public int StemCount { get; set; }

        public bool IsValid { get; set; }
        public string ValidationMessage { get; set; }

        public string UnitPriceText { get { return Pricing.Inr(UnitPrice); } }
        public string LineTotalText { get { return Pricing.Inr(LineTotal); } }
        public string WrappingPriceText { get { return Pricing.Inr(WrappingPrice); } }
        public string RibbonPriceText { get { return Pricing.Inr(RibbonPrice); } }

        public string QuantityLabel
        {
            get { return Quantity == 1 ? "bouquet" : "bouquets"; }
        }
    }

    public class CartSummary
    {
        public List<CartLine> Lines { get; set; }
        public decimal Subtotal { get; set; }
        public decimal DeliveryFee { get; set; }
        public decimal GrandTotal { get; set; }
        public int ItemCount { get; set; }
        public bool HasFreeDelivery { get; set; }
        public bool HasInvalidLines { get; set; }
        public decimal AmountToFreeDelivery { get; set; }

        public string SubtotalText { get { return Pricing.Inr(Subtotal); } }
        public string DeliveryFeeText { get { return DeliveryFee == 0m ? "Complimentary" : Pricing.Inr(DeliveryFee); } }
        public string GrandTotalText { get { return Pricing.Inr(GrandTotal); } }
        public string AmountToFreeDeliveryText { get { return Pricing.Inr(AmountToFreeDelivery); } }
    }

    public class OrderLine
    {
        public string ItemName { get; set; }
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public string WrappingName { get; set; }
        public decimal WrappingPrice { get; set; }
        public string RibbonName { get; set; }
        public decimal RibbonPrice { get; set; }
        public decimal LineTotal { get; set; }

        public string UnitPriceText { get { return Pricing.Inr(UnitPrice); } }
        public string LineTotalText { get { return Pricing.Inr(LineTotal); } }
        public string WrappingPriceText { get { return Pricing.Inr(WrappingPrice); } }
        public string RibbonPriceText { get { return Pricing.Inr(RibbonPrice); } }

        public string OptionsText
        {
            get
            {
                List<string> parts = new List<string>();

                if (!string.IsNullOrWhiteSpace(WrappingName))
                {
                    parts.Add("Wrapping: " + WrappingName +
                        (WrappingPrice > 0m ? " (+" + Pricing.Inr(WrappingPrice) + ")" : " (included)"));
                }

                if (!string.IsNullOrWhiteSpace(RibbonName))
                {
                    parts.Add("Ribbon: " + RibbonName +
                        (RibbonPrice > 0m ? " (+" + Pricing.Inr(RibbonPrice) + ")" : " (included)"));
                }

                return string.Join(" \u00B7 ", parts);
            }
        }
    }

    public class OrderView
    {
        public int OrderId { get; set; }
        public string CustomerName { get; set; }
        public string Phone { get; set; }
        public string DeliveryAddress { get; set; }
        public DateTime DeliveryDate { get; set; }
        public decimal FlowerSubtotal { get; set; }
        public decimal DeliveryFee { get; set; }
        public decimal GrandTotal { get; set; }
        public string Status { get; set; }
        public DateTime OrderDate { get; set; }
        public List<OrderLine> Lines { get; set; }

        public string SubtotalText { get { return Pricing.Inr(FlowerSubtotal); } }
        public string DeliveryFeeText { get { return DeliveryFee == 0m ? "Complimentary" : Pricing.Inr(DeliveryFee); } }
        public string GrandTotalText { get { return Pricing.Inr(GrandTotal); } }
        public string OrderDateText { get { return OrderDate.ToString("dd MMM yyyy"); } }
        public string DeliveryDateText { get { return DeliveryDate.ToString("dddd, dd MMMM yyyy"); } }
    }
}
