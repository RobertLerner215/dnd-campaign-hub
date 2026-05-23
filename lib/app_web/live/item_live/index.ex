defmodule AppWeb.ItemLive.Index do
  use AppWeb, :live_view

  alias App.Items
  alias Phoenix.LiveView.JS

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Items
        <:actions>
          <.link href={~p"/items/new"}>
            <button variant="primary">
              <.icon name="hero-plus" /> New Item
            </button>
          </.link>
        </:actions>
      </.header>

      <.table id="items" rows={@streams.items}>
        <:col :let={{_id, item}} label="Name">{item.name}</:col>
        <:col :let={{_id, item}} label="Attributes">{inspect(item.attributes)}</:col>

        <:action :let={{_id, item}}>
          <.link href={~p"/items/#{item}"} class="mr-3 text-blue-400">
            Show
          </.link>

          <.link href={~p"/items/#{item}/edit"} class="mr-3 text-yellow-400">
            Edit
          </.link>
        </:action>

        <:action :let={{_id, item}}>
          <.link
            phx-click={JS.push("delete", value: %{id: item.id})}
            data-confirm="Are you sure?"
            class="text-red-400"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns[:current_scope]

    items =
      if scope do
        Items.list_items(scope)
      else
        Items.list_items(nil)
      end

    {:ok,
     socket
     |> assign(:page_title, "Listing Items")
     |> stream(:items, items)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    scope = socket.assigns[:current_scope]

    # ✅ THIS FIXES YOUR WARNINGS
    item = Items.get_item!(scope, id)
    {:ok, _} = Items.delete_item(scope, item)

    {:noreply, stream_delete(socket, :items, item)}
  end
end
