defmodule AppWeb.DndLive.InventoryItemLive.Form do
  use AppWeb, :live_view

  alias App.Dnd
  alias App.Dnd.InventoryItem

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-screen bg-slate-950 text-white">
        <div class="mx-auto max-w-3xl px-6 py-10">
          <.link
            navigate={return_path(@return_to, @inventory_item)}
            class="mb-8 inline-flex rounded-lg border border-slate-700 bg-slate-900 px-4 py-2 text-slate-200 transition duration-200 hover:-translate-y-1 hover:border-red-500 hover:bg-slate-800 hover:text-white"
          >
            ← Back
          </.link>

          <h1 class="text-5xl font-bold text-red-500">{@page_title}</h1>
          <p class="mt-2 text-slate-300">
            Add gear, loot, magic items, potions, quest objects, or treasure.
          </p>

          <div class="mt-8 rounded-2xl border border-red-700 bg-slate-900 p-6 shadow-xl">
            <.form for={@form} id="inventory-item-form" phx-change="validate" phx-submit="save">
              <div class="space-y-5">
                <.input field={@form[:name]} type="text" label="Item Name" />

                <div>
                  <label class="mb-1 block text-sm font-semibold text-slate-200">
                    Assign to Character
                  </label>

                  <select
                    name="inventory_item[character_id]"
                    class="w-full rounded-lg border border-slate-700 bg-slate-800 px-4 py-3 text-white transition duration-200 focus:border-red-500 focus:outline-none focus:ring-2 focus:ring-red-600"
                  >
                    <option value="">Party / Unassigned</option>

                    <%= for character <- @characters do %>
                      <option
                        value={character.id}
                        selected={selected_character?(@form[:character_id].value, character.id)}
                      >
                        {character.name}
                      </option>
                    <% end %>
                  </select>

                  <p class="mt-2 text-sm text-slate-400">
                    This creates the association between a saved character and the item.
                  </p>
                </div>

                <.input field={@form[:owner]} type="text" label="Owner Text / Backup Owner" />
                <.input field={@form[:quantity]} type="number" label="Quantity" />
                <.input field={@form[:category]} type="text" label="Category" />
                <.input field={@form[:description]} type="textarea" label="Description / Effect" />
              </div>

              <footer class="mt-6 flex gap-3">
                <button
                  type="submit"
                  phx-disable-with="Saving..."
                  class="rounded-lg bg-red-600 px-5 py-3 font-bold text-white transition duration-200 hover:-translate-y-1 hover:bg-red-700 hover:shadow-xl hover:shadow-red-950"
                >
                  Save Item
                </button>

                <.link
                  navigate={return_path(@return_to, @inventory_item)}
                  class="rounded-lg bg-slate-700 px-5 py-3 font-bold text-white transition duration-200 hover:-translate-y-1 hover:bg-slate-600"
                >
                  Cancel
                </.link>
              </footer>
            </.form>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:characters, Dnd.list_characters())
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    inventory_item = Dnd.get_inventory_item!(id)

    socket
    |> assign(:page_title, "Edit Inventory Item")
    |> assign(:inventory_item, inventory_item)
    |> assign(:form, to_form(Dnd.change_inventory_item(inventory_item)))
  end

  defp apply_action(socket, :new, _params) do
    inventory_item = %InventoryItem{quantity: 1}

    socket
    |> assign(:page_title, "New Inventory Item")
    |> assign(:inventory_item, inventory_item)
    |> assign(:form, to_form(Dnd.change_inventory_item(inventory_item)))
  end

  @impl true
  def handle_event("validate", %{"inventory_item" => inventory_item_params}, socket) do
    changeset = Dnd.change_inventory_item(socket.assigns.inventory_item, inventory_item_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"inventory_item" => inventory_item_params}, socket) do
    save_inventory_item(socket, socket.assigns.live_action, inventory_item_params)
  end

  defp save_inventory_item(socket, :edit, inventory_item_params) do
    case Dnd.update_inventory_item(socket.assigns.inventory_item, inventory_item_params) do
      {:ok, inventory_item} ->
        {:noreply,
         socket
         |> put_flash(:info, "Inventory item updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, inventory_item))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_inventory_item(socket, :new, inventory_item_params) do
    case Dnd.create_inventory_item(inventory_item_params) do
      {:ok, inventory_item} ->
        {:noreply,
         socket
         |> put_flash(:info, "Inventory item created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, inventory_item))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp selected_character?(value, id) when is_integer(value), do: value == id
  defp selected_character?(value, id) when is_binary(value), do: value == Integer.to_string(id)
  defp selected_character?(_, _), do: false

  defp return_path("index", _inventory_item), do: ~p"/dnd/inventory"
  defp return_path("show", inventory_item), do: ~p"/dnd/inventory/#{inventory_item.id}"
end
