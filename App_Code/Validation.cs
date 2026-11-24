using System;
using System.Net.Mail;
using System.Text.RegularExpressions;

namespace BloomSpace
{
    /// <summary>Server-side validation rules used by every form. Never rely on browser checks alone.</summary>
    public static class Validation
    {
        private static readonly Regex NameRx = new Regex(@"^[\p{L}][\p{L} .'\-]{1,99}$", RegexOptions.Compiled);
        private static readonly Regex PhoneRx = new Regex(@"^(?:\+?91|0)?([6-9]\d{9})$", RegexOptions.Compiled);

        public static bool IsValidName(string value)
        {
            if (string.IsNullOrWhiteSpace(value)) return false;
            return NameRx.IsMatch(value.Trim());
        }

        public static bool IsValidEmail(string value)
        {
            if (string.IsNullOrWhiteSpace(value) || value.Length > 256) return false;
            try
            {
                MailAddress address = new MailAddress(value);
                int at = value.IndexOf('@');
                return address.Address == value && at > 0 && value.IndexOf('.', at) > at;
            }
            catch (FormatException)
            {
                return false;
            }
        }

        /// <summary>Returns a clean 10-digit Indian mobile number, or null if the input is not valid.</summary>
        public static string NormalizePhone(string value)
        {
            if (string.IsNullOrWhiteSpace(value)) return null;
            string digits = Regex.Replace(value, @"[\s\-()]", "");
            Match m = PhoneRx.Match(digits);
            return m.Success ? m.Groups[1].Value : null;
        }

        /// <summary>Returns a friendly message if the password is too weak, otherwise null.</summary>
        public static string PasswordProblem(string password)
        {
            if (string.IsNullOrEmpty(password)) return "Please enter a password.";
            if (password.Length < 8) return "Your password must be at least 8 characters long.";
            if (password.Length > 100) return "Your password is too long (maximum 100 characters).";
            if (!Regex.IsMatch(password, @"[A-Za-z]") || !Regex.IsMatch(password, @"\d"))
            {
                return "Your password must contain at least one letter and one number.";
            }
            return null;
        }

        public static bool IsValidAddress(string value)
        {
            if (string.IsNullOrWhiteSpace(value)) return false;
            int len = value.Trim().Length;
            return len >= 10 && len <= 500;
        }
    }
}
