defmodule OceanCat.Broadcaster do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def add_server(server \\ __MODULE__, server_pid) do
    GenServer.cast(server, {:add_server, server_pid})
  end

  def broadcast(server \\ __MODULE__, from, message) do
    GenServer.cast(server, {:broadcast, from, message})
  end

  @impl GenServer
  def init([]) do
    {:ok, MapSet.new()}
  end

  @impl GenServer
  def handle_cast({:add_server, server_pid}, server_set) do
    Process.monitor(server_pid)

    {:noreply, MapSet.put(server_set, server_pid)}
  end

  def handle_cast({:broadcast, from, message}, server_set) do
    IO.puts("broadcasting #{message} from #{inspect(from)}")
    servers_to_tell = MapSet.delete(server_set, from)

    for server_to_tell <- servers_to_tell do
      OceanCat.Server.echo(server_to_tell, message)
    end

    {:noreply, server_set}
  end

  @impl GenServer
  def handle_info({:DOWN, _ref, :process, server_pid, _reason}, server_set) do
    {:noreply, MapSet.delete(server_set, server_pid)}
  end
end
