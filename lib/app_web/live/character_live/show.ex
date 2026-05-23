defmodule AppWeb.CharacterLive.Show do
  use AppWeb, :live_view

  alias App.Dnd

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-screen bg-slate-950 text-white">
        <div class="mx-auto max-w-6xl px-6 py-10">
          <.link
            navigate={~p"/dnd/characters"}
            class="mb-8 inline-flex rounded-lg border border-slate-700 bg-slate-900 px-4 py-2 text-slate-200 transition duration-200 hover:-translate-y-1 hover:border-red-500 hover:bg-slate-800 hover:text-white"
          >
            ← Back to Characters
          </.link>

          <div class="grid grid-cols-1 gap-8 lg:grid-cols-[320px_1fr]">
            <aside class="overflow-hidden rounded-2xl border border-red-800 bg-slate-900 shadow-xl">
              <div class="h-80 bg-slate-950">
                <%= if portrait_url(@character.portrait_path) do %>
                  <img
                    src={portrait_url(@character.portrait_path)}
                    alt={"Portrait for #{@character.name}"}
                    class="h-full w-full object-contain p-3"
                  />
                <% else %>
                  <div class="flex h-full items-center justify-center text-center text-slate-400">
                    <div>
                      <p class="text-6xl">🎲</p>
                      <p class="mt-2">No portrait uploaded</p>
                    </div>
                  </div>
                <% end %>
              </div>

              <div class="p-6">
                <h1 class="text-4xl font-bold text-red-500">{@character.name}</h1>
                <p class="mt-2 text-lg text-slate-300">
                  Level {@character.level} {blank_default(@character.race, "Unknown Race")}
                  {blank_default(@character.class, "Adventurer")}
                </p>

                <div class="mt-6 grid grid-cols-2 gap-3 text-center">
                  <div class="rounded-xl bg-slate-950 p-4">
                    <p class="text-xs text-slate-400">HP</p>
                    <p class="text-2xl font-bold text-emerald-300">{@character.hp}</p>
                  </div>

                  <div class="rounded-xl bg-slate-950 p-4">
                    <p class="text-xs text-slate-400">Armor Class</p>
                    <p class="text-2xl font-bold text-yellow-300">{@character.armor_class}</p>
                  </div>
                </div>

                <.link
                  navigate={~p"/dnd/characters/#{@character.id}/edit?return_to=show"}
                  class="mt-6 block rounded-xl bg-red-600 px-5 py-3 text-center font-bold text-white transition duration-200 hover:-translate-y-1 hover:bg-red-700 hover:shadow-xl hover:shadow-red-950"
                >
                  Edit Character
                </.link>
              </div>
            </aside>

            <main class="space-y-6">
              <section class="rounded-2xl border border-red-800 bg-slate-900 p-6 shadow-xl">
                <h2 class="mb-4 text-2xl font-bold text-red-400">Ability Scores</h2>

                <div class="grid grid-cols-2 gap-4 md:grid-cols-3">
                  <.stat_box label="Strength" value={@character.strength} />
                  <.stat_box label="Dexterity" value={@character.dexterity} />
                  <.stat_box label="Constitution" value={@character.constitution} />
                  <.stat_box label="Intelligence" value={@character.intelligence} />
                  <.stat_box label="Wisdom" value={@character.wisdom} />
                  <.stat_box label="Charisma" value={@character.charisma} />
                </div>
              </section>

              <section class="rounded-2xl border border-red-800 bg-slate-900 p-6 shadow-xl">
                <div class="mb-4 flex items-center justify-between gap-4">
                  <div>
                    <h2 class="text-2xl font-bold text-red-400">Carried Items</h2>
                    <p class="mt-1 text-sm text-slate-400">
                      Inventory items assigned to this character through the character relationship.
                    </p>
                  </div>

                  <.link
                    navigate={~p"/dnd/inventory/new"}
                    class="rounded-lg bg-red-600 px-4 py-2 font-bold text-white transition hover:bg-red-700"
                  >
                    + Add Item
                  </.link>
                </div>

                <%= if Enum.empty?(@character.inventory_items) do %>
                  <div class="rounded-xl border border-dashed border-slate-700 p-6 text-center text-slate-400">
                    No items are assigned to this character yet.
                  </div>
                <% else %>
                  <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
                    <%= for item <- @character.inventory_items do %>
                      <.link
                        navigate={~p"/dnd/inventory/#{item.id}"}
                        class="block rounded-xl border border-slate-700 bg-slate-950 p-4 transition duration-200 hover:-translate-y-1 hover:border-red-500 hover:bg-slate-800"
                      >
                        <div class="flex items-start justify-between gap-3">
                          <div>
                            <h3 class="text-lg font-bold text-red-300">{item.name}</h3>
                            <p class="mt-1 text-sm text-slate-400">
                              {blank_default(item.category, "Uncategorized")}
                            </p>
                          </div>

                          <span class="rounded-full bg-slate-800 px-3 py-1 text-sm font-bold text-yellow-300">
                            x{item.quantity}
                          </span>
                        </div>

                        <p class="mt-3 line-clamp-2 text-sm text-slate-300">
                          {blank_default(item.description, "No description.")}
                        </p>
                      </.link>
                    <% end %>
                  </div>
                <% end %>
              </section>

              <section class="rounded-2xl border border-red-800 bg-slate-900 p-6 shadow-xl">
                <h2 class="mb-4 text-2xl font-bold text-red-400">Character Notes</h2>

                <p class="whitespace-pre-wrap text-slate-300">
                  {blank_default(
                    @character.notes,
                    "No notes have been written for this character yet."
                  )}
                </p>
              </section>
            </main>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  attr :label, :string, required: true
  attr :value, :any, required: true

  def stat_box(assigns) do
    ~H"""
    <div class="rounded-xl border border-slate-700 bg-slate-950 p-4 text-center transition duration-200 hover:-translate-y-1 hover:border-red-500">
      <p class="text-sm text-slate-400">{@label}</p>
      <p class="mt-1 text-3xl font-bold text-white">{@value}</p>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Dnd.subscribe_characters()
      Dnd.subscribe_inventory_items()
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Character")
     |> assign(:character, Dnd.get_character!(id))}
  end

  @impl true
  def handle_info(
        {:updated, %App.Dnd.Character{id: id} = character},
        %{assigns: %{character: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :character, character)}
  end

  def handle_info(
        {:deleted, %App.Dnd.Character{id: id}},
        %{assigns: %{character: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current character was deleted.")
     |> push_navigate(to: ~p"/dnd/characters")}
  end

  def handle_info({_type, %App.Dnd.InventoryItem{}}, socket) do
    {:noreply, assign(socket, :character, Dnd.get_character!(socket.assigns.character.id))}
  end

  def handle_info({_type, %App.Dnd.Character{}}, socket) do
    {:noreply, socket}
  end

  defp portrait_url(nil), do: nil
  defp portrait_url(""), do: nil

  defp portrait_url(path) do
    ~p"/images/characters/#{Path.basename(path)}"
  end

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
