defmodule OceanCat.Server do
  use GenServer

  def start_link(listen_socket) do
    GenServer.start_link(__MODULE__, listen_socket)
  end

  def echo(server, message) do
    GenServer.cast(server, {:echo, message})
  end

  @impl GenServer
  def init(listen_socket) do
    case :gen_tcp.accept(listen_socket) do
      {:ok, socket} ->
        IO.puts("accepted socket #{inspect(socket)}")
        :inet.setopts(socket, [active: :once])
        {:ok, socket}
      error ->
        IO.puts("error accepting on listening socket #{inspect(listen_socket)}")
        {:stop, error}
    end
  end

  @impl GenServer
  def handle_cast({:echo, message}, socket) do
    case :gen_tcp.send(socket, message) do
      :ok -> {:noreply, socket}
      :closed -> {:stop, :closed, socket}
      # TODO {:timeout, rest_data}
    end
  end

  @impl GenServer
  def handle_info({:tcp, socket, data}, _) do
    OceanCat.Broadcaster.broadcast(self(), data)
    :inet.setopts(socket, [active: :once])

    {:noreply, socket}
  end

  def handle_info({:tcp_closed, socket}, _) do
    {:stop, :closed, socket}
  end
end