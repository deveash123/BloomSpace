using System;
using System.Globalization;

namespace BloomSpace
{
    /// <summary>
    /// Central pricing rules. The browser may display an estimate, but the
    /// server always recalculates using these values before saving an order.
    /// </summary>
    public static class Pricing
    {
        public const decimal DeliveryFee = 149m;
        public const decimal FreeDeliveryThreshold = 2000m;
        public const int MaxStemsPerBouquet = 100;
        public const int MaxStemsPerFlowerType = 50;

        public static decimal GetDeliveryFee(decimal subtotal)
        {
            return subtotal >= FreeDeliveryThreshold ? 0m : DeliveryFee;
        }

        /// <summary>Formats a rupee amount with Indian digit grouping (e.g. 1,499).</summary>
        public static string Inr(decimal amount)
        {
            CultureInfo india = CultureInfo.GetCultureInfo("en-IN");
            string format = amount % 1m == 0m ? "N0" : "N2";
            return "\u20B9" + amount.ToString(format, india);
        }

        public static string Inr(int amount)
        {
            return Inr((decimal)amount);
        }
    }
}
