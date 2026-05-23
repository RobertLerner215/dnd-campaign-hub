defmodule AppWeb.FacemashLive do
  use AppWeb, :live_view

  alias AppWeb.Components.Live.{RateComponent, PollComponent}

  def render(assigns) do
    ~H"""
    <div class="p-10">
      <h1 class="text-3xl font-bold mb-6">Pokemon Mash</h1>

      <.live_component module={RateComponent} id="rate-component" images={@images} />
      <.live_component module={PollComponent} id="poll-component" images={@images} />
    </div>
    """
  end

  def mount(_params, _session, socket) do
    images =
      Enum.map(1..8, fn i ->
        AppWeb.Endpoint.static_path("/images/pokemon/pokemon#{i}.png")
      end)

    {:ok, assign(socket, :images, images)}
  end
end
