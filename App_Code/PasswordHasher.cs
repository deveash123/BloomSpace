using System;
using System.Security.Cryptography;

namespace BloomSpace
{
    /// <summary>
    /// Salted PBKDF2 (HMAC-SHA256) password hashing.
    /// Each password gets its own random 16-byte salt; the hash and salt are stored as Base64 text.
    /// </summary>
    public static class PasswordHasher
    {
        private const int SaltSize = 16;
        private const int HashSize = 32;
        public const int DefaultIterations = 100000;

        /// <summary>Creates a new salt and returns the hash for the given password.</summary>
        public static void Hash(string password, out string hashBase64, out string saltBase64, out int iterations)
        {
            byte[] salt = new byte[SaltSize];
            using (RandomNumberGenerator rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(salt);
            }
            iterations = DefaultIterations;
            byte[] hash = Derive(password, salt, iterations);
            hashBase64 = Convert.ToBase64String(hash);
            saltBase64 = Convert.ToBase64String(salt);
        }

        /// <summary>Checks a password against a stored hash using a constant-time comparison.</summary>
        public static bool Verify(string password, string storedHashBase64, string storedSaltBase64, int iterations)
        {
            try
            {
                byte[] salt = Convert.FromBase64String(storedSaltBase64);
                byte[] expected = Convert.FromBase64String(storedHashBase64);
                byte[] actual = Derive(password, salt, iterations);
                return FixedTimeEquals(expected, actual);
            }
            catch (FormatException)
            {
                return false;
            }
        }

        /// <summary>
        /// Does the same amount of work as a real check. Called when the email is unknown so
        /// attackers cannot tell "no such account" from "wrong password" by response time.
        /// </summary>
        public static void BurnTime(string password)
        {
            Derive(password, new byte[SaltSize], DefaultIterations);
        }

        private static byte[] Derive(string password, byte[] salt, int iterations)
        {
            using (Rfc2898DeriveBytes pbkdf2 = new Rfc2898DeriveBytes(password, salt, iterations, HashAlgorithmName.SHA256))
            {
                return pbkdf2.GetBytes(HashSize);
            }
        }

        private static bool FixedTimeEquals(byte[] a, byte[] b)
        {
            if (a == null || b == null || a.Length != b.Length) return false;
            int diff = 0;
            for (int i = 0; i < a.Length; i++)
            {
                diff |= a[i] ^ b[i];
            }
            return diff == 0;
        }
    }
}
