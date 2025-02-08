defmodule DataAccessApiWeb.ShowcaseController do
  use DataAccessApiWeb, :controller
  alias DataAccessApiWeb.OpenAgent, as: OpenAgent

  def get_showcase_all(conn, params) do
    {status, response} = OpenAgent.get_many(
      "showcase",
      params
    )

    Util.respond conn, status, response
  end

  def get_showcase_one(conn, params) do
    {status, response} = OpenAgent.get_one(
      "showcase",
      params["showcase_id"],
      params |> Util.reduce_map_by_keys(["showcase_id"])
    )

    Util.respond conn, status, response
  end
end
