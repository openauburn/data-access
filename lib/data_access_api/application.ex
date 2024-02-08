defmodule DataAccessApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DataAccessApiWeb.Telemetry,
      DataAccessApi.Repo,
      {DNSCluster, query: Application.get_env(:data_access_api, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: DataAccessApi.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: DataAccessApi.Finch},
      # Start a worker by calling: DataAccessApi.Worker.start_link(arg)
      # {DataAccessApi.Worker, arg},
      # Start to serve requests, typically the last entry
      DataAccessApiWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DataAccessApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DataAccessApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
