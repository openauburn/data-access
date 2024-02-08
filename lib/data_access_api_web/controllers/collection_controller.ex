defmodule DataAccessApiWeb.CollectionController do
  use DataAccessApiWeb, :controller
  alias DataAccessApiWeb.OpenAgent, as: OpenAgent

  def get_collections(conn, params) do
    {status, response} = OpenAgent.get_many(
      "collections",
      params
    )

    Util.respond conn, status, response
  end

  def get_collection(conn, params) do
    {status, response} = OpenAgent.get_one(
      "collections",
      params["collection_id"],
      params |> Util.reduce_map_by_keys(["collection_id"])
    )

    Util.respond conn, status, response
  end
end
