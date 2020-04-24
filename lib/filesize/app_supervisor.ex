defmodule Filesize.AppSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      Filesize.StateSupervisor,
      {Filesize.WorkerManager, 4},
      Filesize.WorkerSupervisor
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end

  def crash() do
    Supervisor.stop(__MODULE__, :let_it_crash)
  end
end
