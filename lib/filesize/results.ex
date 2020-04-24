defmodule Filesize.Results do
  use Agent
  @me __MODULE__

  def start_link(_init_arg), do: Agent.start_link(fn -> [] end, name: @me)

  def add(new_result) do
    Agent.update(@me, fn existing_results -> [new_result | existing_results] end)
  end

  def get_all_sorted() do
    Agent.get(@me, fn existing_results ->
      Enum.sort_by(
        existing_results,
        # erstes Element aus Tupel dient als Sortierschlüssel
        &elem(&1, 0),
        # Vergleichsfunktion für absteigende Sortierung
        &>=/2
      )
    end)
  end
end
