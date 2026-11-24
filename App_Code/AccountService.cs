using System;
using System.Data;
using System.Data.SqlClient;

namespace BloomSpace
{
    /// <summary>
    /// Registration and login. Passwords are hashed with PBKDF2-SHA256 and
    /// never stored, logged or placed in a session.
    /// </summary>
    public static class AccountService
    {
        private static readonly string DummyHash = Convert.ToBase64String(new byte[PasswordHasher.HashSize]);
        private static readonly string DummySalt = Convert.ToBase64String(new byte[PasswordHasher.SaltSize]);

        /// <summary>Returns null on success, or a friendly error message.</summary>
        public static string Register(
            string fullName,
            string email,
            string phone,
            string password,
            string confirmPassword)
        {
            fullName = (fullName ?? string.Empty).Trim();
            email = (email ?? string.Empty).Trim().ToLowerInvariant();
            phone = Validation.NormalizePhone(phone);

            if (!Validation.IsValidName(fullName))
            {
                return "Please enter your full name using letters only (2-100 characters).";
            }

            if (!Validation.IsValidEmail(email))
            {
                return "Please enter a valid email address.";
            }

            if (!Validation.IsValidPhone(phone))
            {
                return "Please enter a valid 10-digit Indian mobile number.";
            }

            if (!Validation.IsValidPassword(password))
            {
                return "Password must be at least 8 characters and include a letter and a number.";
            }

            if (!string.Equals(password, confirmPassword, StringComparison.Ordinal))
            {
                return "The two passwords do not match.";
            }

            DataTable existing = Db.GetDataTable(
                "SELECT UserId FROM dbo.Users WHERE Email = @Email",
                Db.P("@Email", email));

            if (existing.Rows.Count > 0)
            {
                return "An account with this email already exists. Please sign in instead.";
            }

            string hash;
            string salt;
            int iterations;

            PasswordHasher.CreateHash(password, out hash, out salt, out iterations);

            try
            {
                Db.ExecuteNonQuery(
                    @"INSERT INTO dbo.Users
                          (FullName, Email, Phone, PasswordHash, PasswordSalt, PasswordIterations)
                      VALUES
                          (@FullName, @Email, @Phone, @Hash, @Salt, @Iterations)",
                    Db.P("@FullName", fullName),
                    Db.P("@Email", email),
                    Db.P("@Phone", phone),
                    Db.P("@Hash", hash),
                    Db.P("@Salt", salt),
                    Db.P("@Iterations", iterations));
            }
            catch (SqlException exception)
            {
                // 2601/2627 = unique index / unique constraint violation.
                if (exception.Number == 2601 || exception.Number == 2627)
                {
                    return "An account with this email already exists. Please sign in instead.";
                }

                throw;
            }

            return null;
        }

        /// <summary>Returns the account when the email and password are correct; otherwise null.</summary>
        public static UserRecord Authenticate(string email, string password)
        {
            if (!Validation.IsValidEmail(email) || string.IsNullOrEmpty(password))
            {
                return null;
            }

            email = email.Trim().ToLowerInvariant();

            DataTable table = Db.GetDataTable(
                @"SELECT TOP 1 UserId, FullName, Email, Phone,
                         PasswordHash, PasswordSalt, PasswordIterations
                  FROM dbo.Users
                  WHERE Email = @Email",
                Db.P("@Email", email));

            if (table.Rows.Count == 0)
            {
                // Perform a dummy derivation so a missing account does not
                // respond noticeably faster than a wrong password.
                PasswordHasher.Verify(
                    password,
                    DummyHash,
                    DummySalt,
                    PasswordHasher.DefaultIterations);

                return null;
            }

            DataRow row = table.Rows[0];

            bool valid = PasswordHasher.Verify(
                password,
                Convert.ToString(row["PasswordHash"]),
                Convert.ToString(row["PasswordSalt"]),
                Convert.ToInt32(row["PasswordIterations"]));

            if (!valid)
            {
                return null;
            }

            return MapUser(row);
        }

        public static UserRecord GetUser(int userId)
        {
            if (userId <= 0)
            {
                return null;
            }

            DataTable table = Db.GetDataTable(
                "SELECT UserId, FullName, Email, Phone FROM dbo.Users WHERE UserId = @UserId",
                Db.P("@UserId", userId));

            return table.Rows.Count == 0 ? null : MapUser(table.Rows[0]);
        }

        private static UserRecord MapUser(DataRow row)
        {
            return new UserRecord
            {
                UserId = Convert.ToInt32(row["UserId"]),
                FullName = Convert.ToString(row["FullName"]),
                Email = Convert.ToString(row["Email"]),
                Phone = Convert.ToString(row["Phone"])
            };
        }
    }
}
