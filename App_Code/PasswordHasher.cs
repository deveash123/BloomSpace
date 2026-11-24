using System;
using System.Security.Cryptography;

namespace BloomSpace
{
    /// <summary>
    /// Salted PBKDF2-SHA256 password hashing.
    /// A different random salt is created for every account, so two users
    /// with the same password never produce the same stored hash.
    /// </summary>
    public static class PasswordHasher
    {
        public const int SaltSize = 16;       // 128-bit salt
        public const int HashSize = 32;       // 256-bit derived key
        public const int DefaultIterations = 100000;

        public static void CreateHash(
            string password,
            out string hashBase64,
            out string saltBase64,
            out int iterations)
        {
            if (string.IsNullOrEmpty(password))
            {
                throw new ArgumentException("Password cannot be empty.", "password");
            }

            iterations = DefaultIterations;

            byte[] salt = new byte[SaltSize];

            using (RandomNumberGenerator generator = RandomNumberGenerator.Create())
            {
                generator.GetBytes(salt);
            }

            byte[] hash = Derive(password, salt, iterations);

            hashBase64 = Convert.ToBase64String(hash);
            saltBase64 = Convert.ToBase64String(salt);
        }

        public static bool Verify(
            string password,
            string hashBase64,
            string saltBase64,
            int iterations)
        {
            if (string.IsNullOrEmpty(password) ||
                string.IsNullOrEmpty(hashBase64) ||
                string.IsNullOrEmpty(saltBase64) ||
                iterations <= 0)
            {
                return false;
            }

            byte[] expected;
            byte[] salt;

            try
            {
                expected = Convert.FromBase64String(hashBase64);
                salt = Convert.FromBase64String(saltBase64);
            }
            catch (FormatException)
            {
                return false;
            }

            byte[] actual = Derive(password, salt, iterations);

            return FixedTimeEquals(actual, expected);
        }

        private static byte[] Derive(string password, byte[] salt, int iterations)
        {
            using (Rfc2898DeriveBytes pbkdf2 = new Rfc2898DeriveBytes(
                password,
                salt,
                iterations,
                HashAlgorithmName.SHA256))
            {
                return pbkdf2.GetBytes(HashSize);
            }
        }

        /// <summary>Constant-time comparison avoids leaking information by timing.</summary>
        private static bool FixedTimeEquals(byte[] left, byte[] right)
        {
            if (left == null || right == null || left.Length != right.Length)
            {
                return false;
            }

            int difference = 0;

            for (int i = 0; i < left.Length; i++)
            {
                difference |= left[i] ^ right[i];
            }

            return difference == 0;
        }
    }
}
