defmodule DataAccessApiWeb.ErrorController do
  use DataAccessApiWeb, :controller

  def add_error(conn, _params) do
    # clean params
    # build sql
    # zip result
    # send
    text conn, "Showing 1 records for 1 ds"
  end
end
