defmodule AppWeb.DndLive.InventoryItemLive.Index do
  use AppWeb, :live_view

  alias App.Dnd

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-screen bg-slate-950 text-white">
        <div class="mx-auto max-w-6xl px-6 py-10">
          <.link
            navigate={~p"/dnd"}
            class="mb-8 inline-flex rounded-lg border border-slate-700 bg-slate-900 px-4 py-2 text-slate-200 transition duration-200 hover:-translate-y-1 hover:border-red-500 hover:bg-slate-800 hover:text-white"
          >
            ← Back to D&D Hub
          </.link>

          <div class="mb-8 flex items-center justify-between gap-4">
            <div>
              <h1 class="text-5xl font-bold text-red-500">Party Inventory</h1>
              <p class="mt-2 text-slate-300">
                Track weapons, treasure, potions, magic items, and who is carrying what.
              </p>
            </div>

            <.link
              navigate={~p"/dnd/inventory/new"}
              class="rounded-xl bg-red-600 px-5 py-3 font-bold text-white transition duration-200 hover:-translate-y-1 hover:bg-red-700 hover:shadow-xl hover:shadow-red-950"
            >
              + New Item
            </.link>
          </div>

          <%= if Enum.empty?(@inventory_items) do %>
            <div class="rounded-2xl border border-red-700 bg-slate-900 p-10 text-center">
              <h2 class="text-2xl font-bold text-red-400">No inventory yet</h2>
              <p class="mt-2 text-slate-300">
                Add weapons, loot, potions, quest items, or treasure.
              </p>
            </div>
          <% else %>
            <div class="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
              <%= for item <- @inventory_items do %>
                <div class="rounded-2xl border border-red-700 bg-slate-900 p-6 shadow-lg transition duration-200 hover:-translate-y-1 hover:bg-slate-800 hover:shadow-xl hover:shadow-red-950">
                  <div class="flex items-start justify-between gap-3">
                    <div>
                      <h2 class="text-2xl font-bold text-red-400">{item.name}</h2>
                      <p class="mt-1 text-sm text-slate-400">
                        {blank_default(item.category, "Uncategorized")}
                      </p>
                    </div>

                    <span class="rounded-full bg-slate-800 px-3 py-1 text-sm font-bold text-yellow-300">
                      x{item.quantity}
                    </span>
                  </div>

                  <div class="mt-4 rounded-xl border border-slate-700 bg-slate-950 p-4">
                    <p class="text-sm text-slate-400">Assigned To</p>

                    <%= if linked_character?(item) do %>
                      <.link
                        navigate={~p"/dnd/characters/#{item.character.id}"}
                        class="mt-1 inline-block text-lg font-bold text-red-300 hover:underline"
                      >
                        {item.character.name}
                      </.link>
                    <% else %>
                      <p class="mt-1 text-lg font-bold text-slate-200">
                        {blank_default(item.owner, "Party / Unassigned")}
                      </p>
                    <% end %>
                  </div>

                  <p class="mt-3 line-clamp-4 whitespace-pre-wrap text-slate-300">
                    {blank_default(item.description, "No description.")}
                  </p>

                  <div class="mt-6 flex flex-wrap gap-3">
                    <.link
                      navigate={~p"/dnd/inventory/#{item.id}"}
                      class="rounded-lg bg-slate-700 px-4 py-2 font-bold text-white transition hover:bg-slate-600"
                    >
                      Open
                    </.link>

                    <.link
                      navigate={~p"/dnd/inventory/#{item.id}/edit"}
                      class="rounded-lg bg-blue-600 px-4 py-2 font-bold text-white transition hover:bg-blue-700"
                    >
                      Edit
                    </.link>

                    <button
                      phx-click="delete"
                      phx-value-id={item.id}
                      data-confirm="Delete this item?"
                      class="rounded-lg bg-red-600 px-4 py-2 font-bold text-white transition hover:bg-red-700"
                    >
                      Delete
                    </button>
                  </div>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Dnd.subscribe_inventory_items()

    {:ok,
     socket
     |> assign(:page_title, "Party Inventory")
     |> assign(:inventory_items, Dnd.list_inventory_items())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    inventory_item = Dnd.get_inventory_item!(id)
    {:ok, _} = Dnd.delete_inventory_item(inventory_item)

    {:noreply, assign(socket, :inventory_items, Dnd.list_inventory_items())}
  end

  @impl true
  def handle_info({_type, _inventory_item}, socket) do
    {:noreply, assign(socket, :inventory_items, Dnd.list_inventory_items())}
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
