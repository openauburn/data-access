defmodule Util do
  import Plug.Conn
  use DataAccessApiWeb, :controller

  def reduce_map_by_keys(map, keys) do
    Enum.reduce(keys, map, fn key, acc -> Map.delete(acc, key) end)
  end

  def wrap_response(data, error) do
    %{data: data, error: (if error != nil, do: error.ext_message, else: nil)}
  end

  def respond(conn, status, response) do
    conn
    |> assign(:response_status, status)
    |> put_status(status.code)
    |> put_resp_content_type("application/json")
    |> text(response)
  end

end
