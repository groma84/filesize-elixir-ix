defmodule Filesize.WorkerSupervisor do
  use DynamicSupervisor

  @me __MODULE__

  def start_link(init_arg), do: DynamicSupervisor.start_link(__MODULE__, init_arg, name: @me)

  def init(_init_arg), do: DynamicSupervisor.init(strategy: :one_for_one)

  def add_worker(), do: {:ok, _pid} = DynamicSupervisor.start_child(@me, Filesize.Worker)

  def stop_worker(pid), do: DynamicSupervisor.terminate_child(@me, pid)
end
