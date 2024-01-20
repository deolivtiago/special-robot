defmodule ClarxCore.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ClarxCoreWeb.Telemetry,
      ClarxCore.Repo,
      {DNSCluster, query: Application.get_env(:clarx, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ClarxCore.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ClarxCore.Finch},
      # Start a worker by calling: ClarxCore.Worker.start_link(arg)
      # {ClarxCore.Worker, arg},
      # Start to serve requests, typically the last entry
      ClarxCoreWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ClarxCore.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ClarxCoreWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
