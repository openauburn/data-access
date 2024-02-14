defmodule DataAccessApiWeb.InternalAgent do


  def add_data(dataset, conn) do
    data = conn.body_params["_json"]
    IO.inspect data
    [status, response] = DAO.build_gen_write_sql(dataset, data) |> DAO.query("Error while adding data.")

    json = Jason.encode!(response)

    {status, json}

  end

  def log_request(conn) do
    IO.puts "in ia"

    [status, _response] = DAO.build_gen_write_sql(
      "requests",
      [%{src_ip: conn.remote_ip |> Tuple.to_list |> Enum.join("."),
       method: conn.method,
       endpoint: conn.request_path,
       params: conn.query_string,
       dataset: (if String.starts_with?(conn.request_path, "/dataset"), do: String.split(conn.request_path, "/") |> Enum.at(2), else: ""),
       timestamp: DateTime.utc_now |> DateTime.to_string |> String.slice(0..-2)}]
    ) |> DAO.query("Error while logging request.")

    # if error, use request_id to insert error
    IO.inspect status
  end

  def log_error(_error) do
    # insert request
    # if error, use request_id to insert error
  end


end
