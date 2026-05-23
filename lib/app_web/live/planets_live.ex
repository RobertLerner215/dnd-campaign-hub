defmodule AppWeb.PlanetsLive do
  use AppWeb, :live_view

  alias App.Planets

  @impl true
  def mount(_params, _session, socket) do
    sort_by = :name
    sort_dir = :asc

    socket =
      socket
      |> assign(:sort_by, sort_by)
      |> assign(:sort_dir, sort_dir)
      |> assign(:planets, Planets.list_planets(sort_by: sort_by, sort_dir: sort_dir))

    {:ok, socket}
  end

  @impl true
  def handle_event("sort", %{"by" => by}, socket) do
    new_sort_by = String.to_existing_atom(by)

    {sort_by, sort_dir} =
      if new_sort_by == socket.assigns.sort_by do
        {new_sort_by, toggle_dir(socket.assigns.sort_dir)}
      else
        {new_sort_by, :asc}
      end

    planets = Planets.list_planets(sort_by: sort_by, sort_dir: sort_dir)

    {:noreply,
     socket
     |> assign(:sort_by, sort_by)
     |> assign(:sort_dir, sort_dir)
     |> assign(:planets, planets)}
  end

  defp toggle_dir(:asc), do: :desc
  defp toggle_dir(:desc), do: :asc

  defp arrow(col, sort_by, sort_dir) do
    cond do
      col != sort_by -> ""
      sort_dir == :asc -> "▲"
      true -> "▼"
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-8">
      <h1 class="text-3xl font-bold text-white mb-6">
        {gettext("Planets (LiveView)")}
      </h1>

      <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
        <table class="w-full text-sm text-left text-slate-300">
          <thead class="text-xs uppercase bg-slate-800 text-slate-200">
            <tr>
              <th class="px-6 py-3">{gettext("ID")}</th>

              <th class="px-6 py-3">
                <button
                  type="button"
                  phx-click="sort"
                  phx-value-by="name"
                  class="flex items-center gap-2 hover:text-white"
                >
                  {gettext("Name")}
                  <span>{arrow(:name, @sort_by, @sort_dir)}</span>
                </button>
              </th>

              <th class="px-6 py-3">
                <button
                  type="button"
                  phx-click="sort"
                  phx-value-by="moons"
                  class="flex items-center gap-2 hover:text-white"
                >
                  {gettext("Moons")}
                  <span>{arrow(:moons, @sort_by, @sort_dir)}</span>
                </button>
              </th>

              <th class="px-6 py-3">
                <button
                  type="button"
                  phx-click="sort"
                  phx-value-by="distance"
                  class="flex items-center gap-2 hover:text-white"
                >
                  {gettext("Distance (Million km)")}
                  <span>{arrow(:distance, @sort_by, @sort_dir)}</span>
                </button>
              </th>

              <th class="px-6 py-3">
                <button
                  type="button"
                  phx-click="sort"
                  phx-value-by="orbital_period"
                  class="flex items-center gap-2 hover:text-white"
                >
                  {gettext("Orbital Period (Days)")}
                  <span>{arrow(:orbital_period, @sort_by, @sort_dir)}</span>
                </button>
              </th>
            </tr>
          </thead>

          <tbody>
            <tr
              :for={p <- @planets}
              class="bg-slate-900 border-b border-slate-800 hover:bg-slate-850"
            >
              <td class="px-6 py-4 font-medium text-white">{p.id}</td>
              <td class="px-6 py-4">{p.name}</td>
              <td class="px-6 py-4">{p.moons}</td>
              <td class="px-6 py-4">{p.distance}</td>
              <td class="px-6 py-4">{p.orbital_period}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <p class="text-slate-400 mt-4">
        {gettext("Click headers to sort ascending or descending.")}
      </p>
    </div>
    """
  end
end
