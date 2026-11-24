using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace BloomSpace
{
    /// <summary>
    /// Small ADO.NET helper used by the whole application.
    /// Every query is parameterised: user input is never concatenated
    /// into SQL text, which protects the site from SQL injection.
    /// </summary>
    public static class Db
    {
        public static string ConnectionString
        {
            get
            {
                ConnectionStringSettings settings = ConfigurationManager.ConnectionStrings["BloomSpaceDB"];

                if (settings == null || string.IsNullOrWhiteSpace(settings.ConnectionString))
                {
                    throw new ConfigurationErrorsException(
                        "The BloomSpaceDB connection string is missing from Web.config.");
                }

                return settings.ConnectionString;
            }
        }

        public static SqlConnection OpenConnection()
        {
            SqlConnection connection = new SqlConnection(ConnectionString);
            connection.Open();
            return connection;
        }

        /// <summary>Creates a parameter and converts null to DBNull.Value.</summary>
        public static SqlParameter P(string name, object value)
        {
            return new SqlParameter(name, value ?? DBNull.Value);
        }

        public static int ExecuteNonQuery(string sql, params SqlParameter[] parameters)
        {
            using (SqlConnection connection = OpenConnection())
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                if (parameters != null && parameters.Length > 0)
                {
                    command.Parameters.AddRange(parameters);
                }

                return command.ExecuteNonQuery();
            }
        }

        public static object ExecuteScalar(string sql, params SqlParameter[] parameters)
        {
            using (SqlConnection connection = OpenConnection())
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                if (parameters != null && parameters.Length > 0)
                {
                    command.Parameters.AddRange(parameters);
                }

                return command.ExecuteScalar();
            }
        }

        public static DataTable GetDataTable(string sql, params SqlParameter[] parameters)
        {
            using (SqlConnection connection = OpenConnection())
            using (SqlCommand command = new SqlCommand(sql, connection))
            using (SqlDataAdapter adapter = new SqlDataAdapter(command))
            {
                if (parameters != null && parameters.Length > 0)
                {
                    command.Parameters.AddRange(parameters);
                }

                DataTable table = new DataTable();
                adapter.Fill(table);
                return table;
            }
        }

        public static int ToInt(object value, int fallback)
        {
            if (value == null || value == DBNull.Value)
            {
                return fallback;
            }

            int result;
            return int.TryParse(Convert.ToString(value), out result) ? result : fallback;
        }

        public static decimal ToDecimal(object value, decimal fallback)
        {
            if (value == null || value == DBNull.Value)
            {
                return fallback;
            }

            decimal result;
            return decimal.TryParse(Convert.ToString(value), out result) ? result : fallback;
        }
    }
}
