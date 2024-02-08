defmodule DataAccessApiWeb.MetadataController do
  use DataAccessApiWeb, :controller
  alias DataAccessApiWeb.OpenAgent, as: OpenAgent

  def get_metadata_all(conn, params) do
    {status, response} = OpenAgent.get_many(
      "metadata",
      params
    )

    Util.respond conn, status, response
  end

  def get_metadata_one(conn, params) do
    {status, response} = OpenAgent.get_one(
      "metadata",
      params["metadata_id"],
      params |> Util.reduce_map_by_keys(["metadata_id"])
    )

    Util.respond conn, status, response
  end
end
