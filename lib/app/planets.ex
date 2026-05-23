defmodule App.Planets do
  @moduledoc """
  A context to retrieve data of our solar system.
  """

  def get_planet(id) do
    case :ets.lookup(:planets, id) do
      [{_id, planet}] -> planet
      [] -> nil
    end
  end

  def get_random_planet do
    list_planets()
    |> Enum.random()
  end

  def list_planets(opts \\ []) do
    sort_by = Keyword.get(opts, :sort_by, :name)
    sort_dir = Keyword.get(opts, :sort_dir, :asc)

    planets =
      :ets.tab2list(:planets)
      |> Enum.map(fn {_id, planet} -> planet end)

    Enum.sort_by(planets, &Map.get(&1, sort_by), sorter(sort_dir))
  end

  defp sorter(:asc), do: &<=/2
  defp sorter(:desc), do: &>=/2
end
