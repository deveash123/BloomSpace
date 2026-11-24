using System;
using System.Net.Mail;
using System.Text.RegularExpressions;

namespace BloomSpace
{
    /// <summary>Server-side validation used by the account, cart and contact pages.</summary>
    public static class Validation
    {
        private static readonly Regex PhonePattern =
            new Regex(@"^[6-9]\d{9}$", RegexOptions.Compiled);

        private static readonly Regex NamePattern =
            new Regex(@"^[A-Za-z][A-Za-z .'\-]{1,99}$", RegexOptions.Compiled);

        private static readonly Regex HasLetter =
            new Regex(@"[A-Za-z]", RegexOptions.Compiled);

        private static readonly Regex HasDigit =
            new Regex(@"\d", RegexOptions.Compiled);

        public static bool IsValidName(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return false;
            }

            return NamePattern.IsMatch(value.Trim());
        }

        public static bool IsValidEmail(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return false;
            }

            string email = value.Trim();

            if (email.Length > 150 || email.Contains(" "))
            {
                return false;
            }

            try
            {
                MailAddress address = new MailAddress(email);
                return string.Equals(address.Address, email, StringComparison.OrdinalIgnoreCase);
            }
            catch (FormatException)
            {
                return false;
            }
        }

        /// <summary>Normalises +91 / spaces / dashes, then checks for a 10-digit Indian mobile.</summary>
        public static string NormalizePhone(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return string.Empty;
            }

            string digits = Regex.Replace(value, @"[^\d]", string.Empty);

            if (digits.StartsWith("91", StringComparison.Ordinal) && digits.Length == 12)
            {
                digits = digits.Substring(2);
            }

            if (digits.StartsWith("0", StringComparison.Ordinal) && digits.Length == 11)
            {
                digits = digits.Substring(1);
            }

            return digits;
        }

        public static bool IsValidPhone(string value)
        {
            string phone = NormalizePhone(value);
            return PhonePattern.IsMatch(phone);
        }

        public static bool IsValidPassword(string password)
        {
            return !string.IsNullOrEmpty(password) &&
                   password.Length >= 8 &&
                   password.Length <= 128 &&
                   HasLetter.IsMatch(password) &&
                   HasDigit.IsMatch(password);
        }

        public static bool IsValidAddress(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return false;
            }

            int length = value.Trim().Length;
            return length >= 10 && length <= 500;
        }

        public static bool IsValidDeliveryDate(DateTime date)
        {
            DateTime today = DateTime.Today;
            return date.Date >= today.AddDays(1) && date.Date <= today.AddDays(30);
        }
    }
}
