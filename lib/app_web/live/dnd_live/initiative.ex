defmodule AppWeb.DndLive.Initiative do
  use AppWeb, :live_view

  alias App.Dnd

  @conditions [
    "Blinded",
    "Charmed",
    "Deafened",
    "Frightened",
    "Grappled",
    "Incapacitated",
    "Invisible",
    "Paralyzed",
    "Poisoned",
    "Prone",
    "Restrained",
    "Stunned",
    "Unconscious"
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:turn_index, 0)
     |> assign(:combatants, [])
     |> assign(:saved_characters, Dnd.list_characters())
     |> assign(:conditions, @conditions)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-950 text-white">
      <div class="mx-auto max-w-6xl px-8 py-10">
        <h1 class="text-5xl font-bold text-red-500">Initiative Tracker</h1>
        <p class="mt-3 text-slate-300">
          Add characters and monsters, track turns, HP, AC, attacks, healing, and conditions.
        </p>

        <div class="mt-8 grid grid-cols-1 gap-6 lg:grid-cols-3">
          <div class="space-y-6">
            <div class="rounded-2xl border border-red-700 bg-slate-900 p-6">
              <h2 class="text-2xl font-bold text-red-400">Add Saved Character</h2>

              <form phx-submit="add_saved_character" class="mt-5 space-y-4">
                <select
                  name="character_id"
                  class="w-full rounded-lg border border-slate-700 bg-slate-800 px-4 py-2 text-white"
                >
                  <option value="">Choose character</option>
                  <%= for character <- @saved_characters do %>
                    <option value={character.id}>
                      {character.name} · Level {character.level} {character.class}
                    </option>
                  <% end %>
                </select>

                <input
                  name="initiative"
                  type="number"
                  class="w-full rounded-lg border border-slate-700 bg-slate-800 px-4 py-2 text-white"
                  placeholder="Initiative roll"
                />

                <button class="w-full rounded-lg bg-red-600 px-4 py-3 font-bold text-white hover:bg-red-700">
                  Add Saved Character
                </button>
              </form>
            </div>

            <div class="rounded-2xl border border-red-700 bg-slate-900 p-6">
              <h2 class="text-2xl font-bold text-red-400">Add Custom Combatant</h2>

              <form phx-submit="add" class="mt-5 space-y-4">
                <input
                  name="name"
                  class="w-full rounded-lg border border-slate-700 bg-slate-800 px-4 py-2 text-white"
                  placeholder="Goblin, Dragon, NPC..."
                />
                <input
                  name="initiative"
                  type="number"
                  class="w-full rounded-lg border border-slate-700 bg-slate-800 px-4 py-2 text-white"
                  placeholder="Initiative"
                />
                <input
                  name="hp"
                  type="number"
                  class="w-full rounded-lg border border-slate-700 bg-slate-800 px-4 py-2 text-white"
                  placeholder="HP"
                />
                <input
                  name="armor_class"
                  type="number"
                  class="w-full rounded-lg border border-slate-700 bg-slate-800 px-4 py-2 text-white"
                  placeholder="Armor Class"
                />

                <select
                  name="type"
                  class="w-full rounded-lg border border-slate-700 bg-slate-800 px-4 py-2 text-white"
                >
                  <option value="player">Player</option>
                  <option value="monster">Monster</option>
                </select>

                <button class="w-full rounded-lg bg-red-600 px-4 py-3 font-bold text-white hover:bg-red-700">
                  Add Custom Combatant
                </button>
              </form>

              <button
                phx-click="clear"
                data-confirm="Clear combat?"
                class="mt-4 w-full rounded-lg border border-slate-700 px-4 py-3 font-bold text-slate-300 hover:bg-slate-800"
              >
                Clear Combat
              </button>
            </div>
          </div>

          <div class="rounded-2xl border border-red-700 bg-slate-900 p-6 lg:col-span-2">
            <div class="flex items-center justify-between gap-4">
              <h2 class="text-2xl font-bold text-red-400">Turn Order</h2>

              <button
                phx-click="next_turn"
                class="rounded-lg bg-blue-600 px-4 py-2 font-bold text-white hover:bg-blue-700"
              >
                Turn Over →
              </button>
            </div>

            <%= if Enum.empty?(@combatants) do %>
              <p class="mt-6 text-slate-400">No combatants yet.</p>
            <% else %>
              <% current = Enum.at(@combatants, @turn_index) %>
              <% next = Enum.at(@combatants, rem(@turn_index + 1, length(@combatants))) %>

              <div class="mt-6 rounded-xl border border-yellow-500 bg-slate-800 p-5">
                <p class="text-sm text-slate-400">Current Turn</p>
                <p class="text-3xl font-bold text-yellow-300">{current.name}</p>
                <p class="mt-1 text-slate-300">
                  Up next: <span class="font-bold text-white">{next.name}</span>
                </p>
              </div>

              <div class="mt-6 rounded-xl border border-red-700 bg-slate-950 p-5">
                <h3 class="text-xl font-bold text-red-400">Combat Action</h3>

                <form phx-submit="combat_action" class="mt-4 grid grid-cols-1 gap-3 md:grid-cols-5">
                  <select
                    name="action"
                    class="rounded-lg border border-slate-700 bg-slate-800 px-4 py-2 text-white"
                  >
                    <option value="damage">Attack / Damage</option>
                    <option value="heal">Heal</option>
                    <option value="condition">Add Condition</option>
                  </select>

                  <select
                    name="target_id"
                    class="rounded-lg border border-slate-700 bg-slate-800 px-4 py-2 text-white"
                  >
                    <%= for combatant <- @combatants do %>
                      <option value={combatant.id}>{combatant.name}</option>
                    <% end %>
                  </select>

                  <input
                    name="value"
                    type="number"
                    placeholder="Damage/heal amount"
                    class="rounded-lg border border-slate-700 bg-slate-800 px-4 py-2 text-white"
                  />

                  <select
                    name="condition"
                    class="rounded-lg border border-slate-700 bg-slate-800 px-4 py-2 text-white"
                  >
                    <%= for condition <- @conditions do %>
                      <option value={condition}>{condition}</option>
                    <% end %>
                  </select>

                  <button class="rounded-lg bg-red-600 px-4 py-2 font-bold text-white hover:bg-red-700">
                    Apply
                  </button>
                </form>
              </div>

              <div class="mt-6 space-y-4">
                <%= for {combatant, index} <- Enum.with_index(@combatants) do %>
                  <div class={[
                    "rounded-xl border p-4",
                    index == @turn_index && "border-yellow-500 bg-slate-800",
                    index != @turn_index && "border-slate-700 bg-slate-950"
                  ]}>
                    <div class="flex items-start justify-between gap-4">
                      <div>
                        <p class="text-2xl font-bold">{index + 1}. {combatant.name}</p>
                        <p class="mt-1 text-slate-400">
                          {String.capitalize(combatant.type)} · Initiative {combatant.initiative} · AC {combatant.armor_class}
                        </p>

                        <p class="mt-3 text-xl font-bold">
                          HP:
                          <span class={[
                            combatant.hp == 0 && "text-red-400",
                            combatant.hp > 0 && "text-green-400"
                          ]}>
                            {combatant.hp}
                          </span>
                          / {combatant.max_hp}
                        </p>

                        <div class="mt-3 flex flex-wrap gap-2">
                          <%= if Enum.empty?(combatant.conditions) do %>
                            <span class="text-slate-500">No conditions</span>
                          <% else %>
                            <%= for condition <- combatant.conditions do %>
                              <button
                                phx-click="remove_condition"
                                phx-value-id={combatant.id}
                                phx-value-condition={condition}
                                class="rounded-full bg-purple-700 px-3 py-1 text-sm text-white hover:bg-purple-800"
                              >
                                {condition} ×
                              </button>
                            <% end %>
                          <% end %>
                        </div>
                      </div>

                      <button
                        phx-click="remove"
                        phx-value-id={combatant.id}
                        class="rounded-lg bg-red-600 px-4 py-2 font-bold text-white hover:bg-red-700"
                      >
                        Remove
                      </button>
                    </div>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event(
        "add_saved_character",
        %{"character_id" => character_id, "initiative" => initiative},
        socket
      ) do
    with {id, _} <- Integer.parse(character_id || ""),
         {initiative_number, _} <- Integer.parse(initiative || "") do
      character = Dnd.get_character!(id)

      combatant = %{
        id: System.unique_integer([:positive]),
        name: character.name,
        initiative: initiative_number,
        type: "player",
        hp: character.hp || 1,
        max_hp: character.hp || 1,
        armor_class: character.armor_class || 10,
        conditions: []
      }

      {:noreply,
       socket
       |> assign(:combatants, sort_combatants([combatant | socket.assigns.combatants]))
       |> assign(:turn_index, 0)}
    else
      _ -> {:noreply, put_flash(socket, :error, "Choose a saved character and enter initiative.")}
    end
  end

  def handle_event("add", params, socket) do
    name = String.trim(params["name"] || "")

    with {initiative, _} <- Integer.parse(params["initiative"] || ""),
         {hp, _} <- Integer.parse(params["hp"] || ""),
         {armor_class, _} <- Integer.parse(params["armor_class"] || ""),
         true <- name != "" do
      combatant = %{
        id: System.unique_integer([:positive]),
        name: name,
        initiative: initiative,
        type: params["type"] || "player",
        hp: hp,
        max_hp: hp,
        armor_class: armor_class,
        conditions: []
      }

      {:noreply,
       socket
       |> assign(:combatants, sort_combatants([combatant | socket.assigns.combatants]))
       |> assign(:turn_index, 0)}
    else
      _ -> {:noreply, put_flash(socket, :error, "Add name, initiative, HP, and AC.")}
    end
  end

  def handle_event("combat_action", params, socket) do
    id = String.to_integer(params["target_id"])
    action = params["action"]
    value = String.trim(params["value"] || "")
    condition = params["condition"] || ""

    combatants =
      Enum.map(socket.assigns.combatants, fn combatant ->
        if combatant.id == id do
          case action do
            "damage" -> apply_combat_action(combatant, "damage", value)
            "heal" -> apply_combat_action(combatant, "heal", value)
            "condition" -> apply_combat_action(combatant, "condition", condition)
            _ -> combatant
          end
        else
          combatant
        end
      end)

    {:noreply, assign(socket, :combatants, combatants)}
  end

  def handle_event("next_turn", _params, socket) do
    if Enum.empty?(socket.assigns.combatants) do
      {:noreply, socket}
    else
      next_index = rem(socket.assigns.turn_index + 1, length(socket.assigns.combatants))
      {:noreply, assign(socket, :turn_index, next_index)}
    end
  end

  def handle_event("remove_condition", %{"id" => id, "condition" => condition}, socket) do
    id = String.to_integer(id)

    combatants =
      Enum.map(socket.assigns.combatants, fn combatant ->
        if combatant.id == id do
          %{combatant | conditions: List.delete(combatant.conditions, condition)}
        else
          combatant
        end
      end)

    {:noreply, assign(socket, :combatants, combatants)}
  end

  def handle_event("remove", %{"id" => id}, socket) do
    id = String.to_integer(id)
    combatants = Enum.reject(socket.assigns.combatants, &(&1.id == id))

    turn_index =
      if Enum.empty?(combatants),
        do: 0,
        else: min(socket.assigns.turn_index, length(combatants) - 1)

    {:noreply, assign(socket, combatants: combatants, turn_index: turn_index)}
  end

  def handle_event("clear", _params, socket) do
    {:noreply, assign(socket, combatants: [], turn_index: 0)}
  end

  defp apply_combat_action(combatant, "damage", value) do
    case Integer.parse(value) do
      {amount, _} -> %{combatant | hp: max(combatant.hp - amount, 0)}
      _ -> combatant
    end
  end

  defp apply_combat_action(combatant, "heal", value) do
    case Integer.parse(value) do
      {amount, _} -> %{combatant | hp: min(combatant.hp + amount, combatant.max_hp)}
      _ -> combatant
    end
  end

  defp apply_combat_action(combatant, "condition", condition) do
    %{combatant | conditions: Enum.uniq([condition | combatant.conditions])}
  end

  defp sort_combatants(combatants), do: Enum.sort_by(combatants, & &1.initiative, :desc)
end
