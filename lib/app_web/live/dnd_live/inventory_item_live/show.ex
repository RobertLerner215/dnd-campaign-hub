defmodule AppWeb.DndLive.InventoryItemLive.Show do
  use AppWeb, :live_view

  alias App.Dnd

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-screen bg-slate-950 text-white">
        <div class="mx-auto max-w-4xl px-6 py-10">
          <div class="mb-8 flex items-center justify-between gap-4">
            <div>
              <h1 class="text-5xl font-bold text-red-500">{@inventory_item.name}</h1>
              <p class="mt-2 text-slate-300">Inventory item details</p>
            </div>

            <div class="flex gap-3">
              <.link
                navigate={~p"/dnd/inventory"}
                class="rounded-lg bg-slate-700 px-4 py-2 font-bold text-white transition hover:bg-slate-600"
              >
                Back
              </.link>

              <.link
                navigate={~p"/dnd/inventory/#{@inventory_item.id}/edit?return_to=show"}
                class="rounded-lg bg-red-600 px-4 py-2 font-bold text-white transition hover:bg-red-700"
              >
                Edit
              </.link>
            </div>
          </div>

          <div class="rounded-2xl border border-red-700 bg-slate-900 p-6 shadow-xl">
            <div class="grid grid-cols-1 gap-4 md:grid-cols-3">
              <div class="rounded-xl bg-slate-800 p-4">
                <p class="text-sm text-slate-400">Assigned To</p>

                <%= if linked_character?(@inventory_item) do %>
                  <.link
                    navigate={~p"/dnd/characters/#{@inventory_item.character.id}"}
                    class="text-xl font-bold text-red-300 hover:underline"
                  >
                    {@inventory_item.character.name}
                  </.link>
                <% else %>
                  <p class="text-xl font-bold">
                    {blank_default(@inventory_item.owner, "Party / Unassigned")}
                  </p>
                <% end %>
              </div>

              <div class="rounded-xl bg-slate-800 p-4">
                <p class="text-sm text-slate-400">Quantity</p>
                <p class="text-xl font-bold text-yellow-300">x{@inventory_item.quantity}</p>
              </div>

              <div class="rounded-xl bg-slate-800 p-4">
                <p class="text-sm text-slate-400">Category</p>
                <p class="text-xl font-bold">
                  {blank_default(@inventory_item.category, "Uncategorized")}
                </p>
              </div>
            </div>

            <%= if linked_character?(@inventory_item) do %>
              <div class="mt-6 rounded-xl border border-red-700 bg-slate-950 p-5">
                <p class="text-sm text-slate-400">Character Association</p>
                <p class="mt-2 text-slate-300">
                  This item belongs to <span class="font-bold text-red-300">{@inventory_item.character.name}</span>.
                  This relationship is stored through the inventory item's <span class="font-mono text-yellow-300">character_id</span>.
                </p>
              </div>
            <% end %>

            <div class="mt-6 rounded-xl bg-slate-800 p-5">
              <p class="text-sm text-slate-400">Description / Effect</p>
              <p class="mt-2 whitespace-pre-wrap text-lg text-slate-200">
                {blank_default(@inventory_item.description, "No description.")}
              </p>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket), do: Dnd.subscribe_inventory_items()

    {:ok,
     socket
     |> assign(:page_title, "Show Inventory Item")
     |> assign(:inventory_item, Dnd.get_inventory_item!(id))}
  end

  @impl true
  def handle_info({:updated, inventory_item}, socket) do
    current_item = socket.assigns.inventory_item

    if inventory_item.id == current_item.id do
      {:noreply, assign(socket, :inventory_item, Dnd.get_inventory_item!(inventory_item.id))}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:deleted, inventory_item}, socket) do
    current_item = socket.assigns.inventory_item

    if inventory_item.id == current_item.id do
      {:noreply,
       socket
       |> put_flash(:error, "The current inventory item was deleted.")
       |> push_navigate(to: ~p"/dnd/inventory")}
    else
      {:noreply, socket}
    end
  end

  def handle_info({_type, _inventory_item}, socket) do
    {:noreply, socket}
  end

  defp linked_character?(%{character: %App.Dnd.Character{}}), do: true
  defp linked_character?(_item), do: false

  defp blank_default(nil, default), do: default

  defp blank_default(value, default) when is_binary(value) do
    if String.trim(value) == "" do
      default
    else
      value
    end
  end

  defp blank_default(value, _default), do: value
end
