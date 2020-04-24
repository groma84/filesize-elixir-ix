defmodule Filesize.StateSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg)
  end

  @impl true
  def init(_init_arg) do
    children = [
      Filesize.Results,
      Filesize.Queue
    ]

    Supervisor.init(children, strategy: :one_for_all, max_restarts: 0)
  end
end
