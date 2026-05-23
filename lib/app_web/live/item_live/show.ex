defmodule AppWeb.ItemLive.Show do
  use AppWeb, :live_view

  alias App.Items

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Item {@item.id}
        <:subtitle>This is a item record from your database.</:subtitle>
        <:actions>
          <.link navigate={~p"/items"}>
            <button>
              <.icon name="hero-arrow-left" />
            </button>
          </.link>

          <.link navigate={~p"/items/#{@item}/edit?return_to=show"}>
            <button variant="primary">
              <.icon name="hero-pencil-square" /> Edit item
            </button>
          </.link>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@item.name}</:item>
        <:item title="Attributes">{@item.attributes}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Items.subscribe_items(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Item")
     |> assign(:item, Items.get_item!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %App.Items.Item{id: id} = item},
        %{assigns: %{item: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :item, item)}
  end

  def handle_info(
        {:deleted, %App.Items.Item{id: id}},
        %{assigns: %{item: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current item was deleted.")
     |> push_navigate(to: ~p"/items")}
  end

  def handle_info({type, %App.Items.Item{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
