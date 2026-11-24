using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web;

namespace BloomSpace
{
    /// <summary>Small ADO.NET helpers shared by all pages. Every query uses SqlParameters.</summary>
    public static class Db
    {
        /// <summary>Opens a new connection using the "BloomSpaceDB" connection string from Web.config.</summary>
        public static SqlConnection Open()
        {
            string cs = ConfigurationManager.ConnectionStrings["BloomSpaceDB"].ConnectionString;
            SqlConnection con = new SqlConnection(cs);
            con.Open();
            return con;
        }

        /// <summary>Creates a parameter. Never build SQL by joining strings - always use this.</summary>
        public static SqlParameter P(string name, object value)
        {
            return new SqlParameter(name, value);
        }

        /// <summary>Runs a SELECT and returns the rows as a DataTable.</summary>
        public static DataTable Table(string sql, params SqlParameter[] parameters)
        {
            using (SqlConnection con = Open())
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                if (parameters != null) cmd.Parameters.AddRange(parameters);
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }

                // Seamlessly upgrade legacy .svg references to high-definition .jpg photos when available
                if (dt.Columns.Contains("ImageUrl"))
                {
                    foreach (DataRow row in dt.Rows)
                    {
                        if (row["ImageUrl"] != DBNull.Value)
                        {
                            string img = (string)row["ImageUrl"];
                            if (img.EndsWith(".svg", StringComparison.OrdinalIgnoreCase))
                            {
                                string jpgCandidate = img.Substring(0, img.Length - 4) + ".jpg";
                                string physicalPath = HttpContext.Current != null
                                    ? HttpContext.Current.Server.MapPath(jpgCandidate)
                                    : null;
                                if (physicalPath != null && System.IO.File.Exists(physicalPath))
                                {
                                    row["ImageUrl"] = jpgCandidate;
                                }
                            }
                        }
                    }
                }

                return dt;
            }
        }

        /// <summary>Runs a SELECT that returns a single value.</summary>
        public static object Scalar(string sql, params SqlParameter[] parameters)
        {
            using (SqlConnection con = Open())
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                if (parameters != null) cmd.Parameters.AddRange(parameters);
                return cmd.ExecuteScalar();
            }
        }

        /// <summary>Delivery fee (INR) from Web.config. Falls back to 99 if the setting is missing or invalid.</summary>
        public static decimal DeliveryFee
        {
            get
            {
                decimal fee;
                string raw = ConfigurationManager.AppSettings["DeliveryFee"];
                if (decimal.TryParse(raw, NumberStyles.Number, CultureInfo.InvariantCulture, out fee) && fee >= 0m)
                {
                    return fee;
                }
                return 99m;
            }
        }
    }

    /// <summary>Formats money as Indian Rupees, e.g. "₹1,250.00".</summary>
    public static class Money
    {
        private static readonly CultureInfo Indian = new CultureInfo("en-IN");

        public static string Rupees(decimal amount)
        {
            // ₹ is the rupee sign; written as an escape so file encoding never matters.
            return "₹" + amount.ToString("N2", Indian);
        }

        /// <summary>Plain number for data-* attributes read by JavaScript (always uses a dot).</summary>
        public static string Plain(decimal amount)
        {
            return amount.ToString("0.00", CultureInfo.InvariantCulture);
        }
    }

    /// <summary>Writes technical errors to the debug/trace output instead of showing them to customers.</summary>
    public static class ErrorLog
    {
        public static void Write(Exception ex)
        {
            try
            {
                System.Diagnostics.Trace.TraceError("BloomSpace error: " + ex.ToString());
            }
            catch
            {
                // Logging must never crash the website.
            }
        }
    }
}
