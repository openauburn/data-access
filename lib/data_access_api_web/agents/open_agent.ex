defmodule DataAccessApiWeb.OpenAgent do
  def get_many(table, params) do

    [status, response] = DAO.build_gen_read_sql(table, params)
    |> DAO.paginate_sql_response(params)
    |> DAO.query("Malformed request.")

    json = Jason.encode!(response)

    {status, json}
  end

  def get_one(table, record_id, params) do

    [status, response] = DAO.build_gen_read_sql(table, %{"_id" => record_id, "show" => Map.get(params, "show", "[*]")})
    |> DAO.query("Malformed request.")

    json = Jason.encode!(response)

    {status, json}
  end

  def metadata_read_update(table) do
      DAO.append_metadata_read_update_sql(table)
        |> DAO.query("Error updating metadata.")
  end
end
