defmodule DAO do

  def build_gen_read_sql(table, params) do
    reserved_params = ["show", "page", "page_size", "sort"]

    # show=f1,f2,f3,f4...
    select_fields = params |> Map.get("show", "[*]") |> String.slice(1..-2)

    # f1=v1,v2&f2=v2...
    fields = Util.reduce_map_by_keys(params, reserved_params)
    # handle duplicate field params => turn f1=v1&f1=v2 into f1=v1,v2
    fields = fields |> Enum.map(
      fn {k,v} ->
        v = if String.at(v, 0) == "[" and String.at(v, -1) == "]" do
          v = String.slice(v, 1..-2)
          # check for brackets, then split on str
          v |> String.split(",") |> Enum.map(fn s -> "'#{s}'" end) |> Enum.join(", ")
        else
          "'#{v}'"
        end
        "#{k} IN " <> Enum.join(["(", ")"], v)
      end)
      # tags && ARRAY['meep']
      |> Enum.join(" AND ")
    fields = if fields == "", do: "TRUE", else: fields

    sql = """
    SELECT #{select_fields}
    FROM #{table}
    WHERE #{fields}
    """

    sql
  end

  def build_gen_write_sql(table, objects) do

    _num_objects = length(objects)

    fields = Enum.at(objects, 0) |> Map.keys |> Enum.join(", ")

    all_values = objects |> Enum.map(fn o ->
      _values = "(#{Map.values(o) |> Enum.map(fn v -> "'#{v}'" end) |> Enum.join(", ")})"
      #values = if num_objects > 1, do: "(#{values})", else: values
    end)
      |> Enum.join(",\n")

    sql = """
    INSERT INTO #{table}(#{fields})
    values#{all_values}
    RETURNING *
    """
    sql
  end


  def build_request_log_sql(conn) do
    IO.puts "in dao"
    src_ip = conn.remote_ip |> Tuple.to_list |> Enum.join(".")
    method = conn.method
    endpoint = conn.request_path
    params = conn.query_string
    dataset = if String.starts_with?(endpoint, "/dataset"), do: String.split(endpoint, "/") |> Enum.at(2), else: ""
    timestamp = DateTime.utc_now |> DateTime.to_string |> String.slice(0..-2)

    IO.puts "building sql"
    values = [src_ip, method, endpoint, params, dataset, timestamp] |> Enum.map(fn v -> "'#{v}'" end) |> Enum.join(", ")

    sql = """
    INSERT INTO requests(src_ip, method, endpoint, params, dataset, timestamp)
    values(#{values})
    """
    sql

  end



  def paginate_sql_response(sql, params) do
    [sort_field, sort_order] = params |> Map.get("sort", ",") |> String.split(",")
    sort_field = if sort_field == "", do: "_id", else: sort_field
    sort_order = if String.contains?(sort_order |> String.downcase(), "desc"), do: "desc", else: "asc"

    # Determine pagination
    page = params |> Map.get("page", 1)
    page_size = params |> Map.get("page_size", 50)

    {page_i, _} = :string.to_integer(to_charlist(page))
    {page_size_i, _} = :string.to_integer(to_charlist(page_size))

    offset = (page_i - 1) * page_size_i
    limit = page_size_i

    sql = """
    #{sql}ORDER BY #{sort_field} #{sort_order}
    OFFSET #{offset}
    LIMIT #{limit}
    """

    sql
  end

  def query(sql, ext_err_message) do
    IO.puts sql
    [status, response] = try do
      {:ok, result} = Ecto.Adapters.SQL.query(DataAccessApi.Repo, sql, [])
      data =
        result.rows
        |> Enum.map(fn row ->
          Enum.zip(result.columns, row) |> Map.new()
        end)
      response = data |> Util.wrap_response(nil)
      status = %{code: 200, error: nil}
      [status, response]
    rescue
      reason ->
        IO.inspect reason
        reason = elem(reason.term, 1)
        error = reason |> build_query_error_map(ext_err_message)
        response = [] |> Util.wrap_response(error)
        status = %{code: 400, error: error}
        [status, response]
    end

    [status, response]

  end

  def build_query_error_map(result, ext_message) do
    %{message: result.postgres.message, routine: result.postgres.routine, query: result.query, ext_message: ext_message}
  end

end
