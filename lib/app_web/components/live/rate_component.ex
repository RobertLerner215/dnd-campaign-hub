defmodule AppWeb.Components.Live.RateComponent do
  use AppWeb, :live_component

  alias AppWeb.Components.Live.PollComponent

  def render(assigns) do
    ~H"""
    <div class="mb-8">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <%= for {image, index} <- @selected do %>
          <button
            phx-click="rate"
            phx-value-index={index}
            phx-target={@myself}
            class="border rounded-xl overflow-hidden shadow hover:scale-[1.02] transition"
          >
            <img
              src={image}
              class="h-80 w-full object-contain bg-white brightness-75 hover:brightness-110 transition duration-300"
            />
          </button>
        <% end %>
      </div>
    </div>
    """
  end

  def update(assigns, socket) do
    selected =
      assigns.images
      |> Enum.with_index()
      |> Enum.take_random(2)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:selected, selected)}
  end

  def handle_event("rate", %{"index" => index}, socket) do
    index = String.to_integer(index)

    send_update(PollComponent, id: "poll-component", index: index)

    selected =
      socket.assigns.images
      |> Enum.with_index()
      |> Enum.take_random(2)

    {:noreply, assign(socket, :selected, selected)}
  end
end
