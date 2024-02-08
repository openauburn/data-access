defmodule DataAccessApiWeb.Logging do
  alias DataAccessApiWeb.InternalAgent, as: InternalAgent

  def init(default), do: nil

  def call(conn, _params) do
    # IO.puts("Logging")
    # InternalAgent.log_request(conn)
    # IO.puts("leaving logging")
    conn
  end
end
