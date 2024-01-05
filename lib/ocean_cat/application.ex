defmodule OceanCat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: OceanCat.Worker.start_link(arg)
      # {OceanCat.Worker, arg}
      {DynamicSupervisor, name: OceanCat.DynamicSupervisor, strategy: :one_for_one},
      OceanCat.Broadcaster,
      {OceanCat.Listener, [5000]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: OceanCat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
