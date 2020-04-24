defmodule Filesize.Queue do
  use GenServer
  @me __MODULE__

  def start_link(init_arg) do
    IO.puts("Queue start_link")
    GenServer.start_link(__MODULE__, init_arg, name: @me)
  end

  @impl true
  def init(_init_arg), do: {:ok, []}

  def add_directory(directory) do
    GenServer.call(@me, {:add, directory})
    Filesize.WorkerManager.start_workers()
  end

  def get_next_directory(), do: GenServer.call(@me, {:get_next_directory})

  def directory_done(directory), do: GenServer.call(@me, {:directory_done, directory})

  @impl true
  def handle_call({:add, directory}, _from, state) do
    {:reply, nil, [directory | state]}
  end

  @impl true
  def handle_call({:get_next_directory}, _from, state) do
    case state do
      [] -> {:reply, nil, state}
      [next_dir | rest] -> {:reply, next_dir, rest}
    end
  end

  @impl true
  def handle_call({:directory_done, directory}, _from, state) do
    {:reply, :ok, List.delete(state, directory)}
  end

  @impl true
  def terminate(_reason, _state) do
    IO.puts("Queue terminate")
  end
end
