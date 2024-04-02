defmodule DataAccessApiWeb.OpenAgent do

  def get_many(table, params) do

    [status, response] = DAO.build_gen_read_sql(table, params)
      |> DAO.append_metadata_read_update_sql(table)
      |> DAO.paginate_sql_response(params)
      |> DAO.query("Malformed request.")

    json = Jason.encode!(response)

    {status, json}
  end

  def get_one(table, record_id, params) do
    # Only valid filters on single element are _id and show
    [status, response] = DAO.build_gen_read_sql(table, %{"_id"=>record_id, "show"=>Map.get(params, "show", "[*]")})
     |> DAO.append_metadata_read_update_sql(table)
     |> DAO.query("Malformed request.")

    json = Jason.encode!(response)

    {status, json}
  end


end
