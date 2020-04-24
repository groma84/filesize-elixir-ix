defmodule Filesize.WorkerManager do
  use GenServer

  @me __MODULE__

  def start_link(max_workers), do: GenServer.start_link(__MODULE__, max_workers, name: @me)

  @impl true
  def init(max_workers), do: {:ok, %{max_workers: max_workers, current_workers: 0}}

  def start_workers(), do: GenServer.call(@me, :start_workers)

  def done(pid), do: GenServer.call(@me, {:stop_worker, pid})

  def started(), do: GenServer.cast(@me, :worker_started)

  @impl true
  def handle_call(:start_workers, _from, state) do
    if state.current_workers < state.max_workers do
      state.current_workers..(state.max_workers - 1)
      |> Enum.each(fn _ -> Filesize.WorkerSupervisor.add_worker() end)
    end

    {:reply, nil, state}
  end

  @impl true
  def handle_call({:stop_worker, pid}, _from, state) do
    Filesize.WorkerSupervisor.stop_worker(pid)
    {:reply, nil, %{state | current_workers: state.current_workers - 1}}
  end

  @impl true
  def handle_cast(:worker_started, state) do
    {:noreply, %{state | current_workers: state.current_workers + 1}}
  end
end
