defmodule Filesize.Worker do
  use GenServer, restart: :transient

  def start_link(init_arg) do
    IO.puts("Worker start_link")
    GenServer.start_link(__MODULE__, init_arg)
  end

  @impl true
  def init(_init_arg) do
    Filesize.WorkerManager.started()
    Process.send_after(self(), :traverse_one_directory, 0)
    {:ok, nil}
  end

  @impl true
  def terminate(_reason, _state) do
    Filesize.WorkerManager.done(self())
  end

  @impl true
  def handle_info(:traverse_one_directory, _from) do
    work_dir = Filesize.Queue.get_next_directory()
    traverse(work_dir)
    Filesize.Queue.directory_done(work_dir)

    {:noreply, nil}
  end

  defp traverse(nil) do
    Filesize.WorkerManager.done(self())
  end

  defp traverse(directory) do
    File.ls!(directory)
    |> Enum.map(fn path ->
      absolute_path = Path.join(directory, path)

      if File.dir?(absolute_path) do
        Filesize.Queue.add_directory(absolute_path)
      else
        file_info = File.stat!(absolute_path)
        Filesize.Results.add({file_info.size, absolute_path})
      end
    end)

    send(self(), :traverse_one_directory)
  end
end
