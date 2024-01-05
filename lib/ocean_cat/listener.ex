defmodule OceanCat.Listener do
  use GenServer

  def start_link([port]) do
    GenServer.start_link(__MODULE__, [port], name: __MODULE__)
  end

  @impl GenServer
  def init([port]) do
    with {:ok, listen_socket} <-
           :gen_tcp.listen(port, active: false, packet: :line, reuseaddr: true) do
      send(self(), :listen)
      {:ok, listen_socket}
    end
  end

  @impl GenServer
  def handle_info(:listen, listen_socket) do
    {:ok, server_pid} =
      DynamicSupervisor.start_child(OceanCat.DynamicSupervisor, {OceanCat.Server, listen_socket})

    OceanCat.Broadcaster.add_server(server_pid)
    send(self(), :listen)

    {:noreply, listen_socket}
  end
end
