defmodule DataAccessApiWeb.DatasetController do
  use DataAccessApiWeb, :controller
  alias DataAccessApiWeb.InternalAgent
  alias DataAccessApiWeb.OpenAgent, as: OpenAgent

  def get_dataset(conn, params) do

    if !Map.has_key?(params, "_incognito") do
      OpenAgent.metadata_read_update(format_table(params["dataset_id"]))
    end

    {status, response} = OpenAgent.get_many(
      format_table(params["dataset_id"]),
      params |> Util.reduce_map_by_keys(["dataset_id", "_incognito"])
    )

    Util.respond conn, status, response

  end

  def get_datum(conn, params) do

    if !Map.has_key?(params, "_incognito") do
      OpenAgent.metadata_read_update(format_table(params["dataset_id"]))
    end

    {status, response} = OpenAgent.get_one(
      format_table(params["dataset_id"]),
      params["datum_id"],
      params |> Util.reduce_map_by_keys(["dataset_id", "datum_id", "_incognito"])
    )

    Util.respond conn, status, response
  end

  def add_data(conn, params) do

    {status, response} = InternalAgent.add_data(
      format_table(params["dataset_id"]),
      conn
    )

    Util.respond conn, status, response
  end

  defp format_table(table) do
    "ds_" <> table
  end

end
