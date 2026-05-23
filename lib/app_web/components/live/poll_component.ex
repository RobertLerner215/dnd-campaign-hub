defmodule AppWeb.Components.Live.PollComponent do
  use AppWeb, :live_component

  def mount(socket) do
    {:ok,
     socket
     |> assign(:images, [])
     |> assign(:votes, %{})
     |> assign(:total_votes, 0)
     |> assign(:show_results, false)}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <div class="flex items-center gap-4">
        <h2 class="text-2xl font-bold">Total Votes: {@total_votes}</h2>

        <button
          phx-click="toggle-results"
          phx-target={@myself}
          disabled={@total_votes == 0}
          class="px-4 py-2 bg-blue-600 text-white rounded disabled:opacity-50"
        >
          Show / Hide Results
        </button>
      </div>

      <%= if @show_results do %>
        <div class="space-y-4">
          <%= for {image, index} <- Enum.with_index(@images) do %>
            <div class="flex items-center gap-4">
              <img src={image} class="w-16 h-16 object-contain bg-white rounded" />

              <div class="w-full">
                <div class="w-full bg-gray-200 rounded-full h-4 dark:bg-gray-700">
                  <div
                    class="bg-blue-600 h-4 rounded-full transition-all duration-300"
                    style={"width: #{percent(Map.get(@votes, index, 0), @total_votes)}%"}
                  >
                  </div>
                </div>

                <p class="text-sm mt-1">
                  {Map.get(@votes, index, 0)} votes
                  ({percent(Map.get(@votes, index, 0), @total_votes)}%)
                </p>
              </div>
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  def update(%{images: images}, socket) do
    votes =
      images
      |> Enum.with_index()
      |> Enum.map(fn {_image, index} -> {index, 0} end)
      |> Enum.into(%{})

    {:ok,
     socket
     |> assign(:images, images)
     |> assign(:votes, votes)
     |> assign(:total_votes, 0)
     |> assign(:show_results, false)}
  end

  def update(%{index: index}, socket) do
    votes = Map.update!(socket.assigns.votes, index, &(&1 + 1))

    {:ok,
     socket
     |> assign(:votes, votes)
     |> assign(:total_votes, socket.assigns.total_votes + 1)}
  end

  def handle_event("toggle-results", _params, socket) do
    {:noreply, assign(socket, :show_results, !socket.assigns.show_results)}
  end

  defp percent(_votes, 0), do: 0
  defp percent(votes, total), do: round(votes / total * 100)
end
