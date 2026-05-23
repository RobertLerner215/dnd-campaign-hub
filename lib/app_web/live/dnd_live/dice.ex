defmodule AppWeb.DndLive.Dice do
  use AppWeb, :live_view

  alias Phoenix.PubSub

  @topic "dnd_dice"
  @dice_types ["d4", "d6", "d8", "d10", "d12", "d20", "d100"]

  def mount(_params, _session, socket) do
    if connected?(socket), do: PubSub.subscribe(App.PubSub, @topic)

    {:ok,
     assign(socket,
       player_name: "",
       dice_type: "d20",
       dice_count: 1,
       roll_mode: "normal",
       modifier: 0,
       dice_types: @dice_types,
       rolls: []
     )}
  end

  def handle_event("join", %{"player_name" => name}, socket) do
    player_name = String.trim(name)

    if player_name != "" do
      result = %{
        type: :join,
        player: player_name,
        message: "#{player_name} has joined the table.",
        time: current_time()
      }

      PubSub.broadcast(App.PubSub, @topic, {:dice_roll, result})
    end

    {:noreply, assign(socket, :player_name, player_name)}
  end

  def handle_event("roll", %{"roll" => params}, socket) do
    dice_type = params["dice_type"] || "d20"
    dice_count = params["dice_count"] |> parse_int() |> clamp(1, 20)
    roll_mode = params["roll_mode"] || "normal"
    modifier = parse_int(params["modifier"])

    sides =
      dice_type
      |> String.replace("d", "")
      |> String.to_integer()

    result =
      build_roll_result(%{
        player: blank_to_default(socket.assigns.player_name, "Unknown Adventurer"),
        dice_type: dice_type,
        dice_count: dice_count,
        roll_mode: roll_mode,
        modifier: modifier,
        sides: sides
      })

    PubSub.broadcast(App.PubSub, @topic, {:dice_roll, result})

    {:noreply,
     assign(socket,
       dice_type: dice_type,
       dice_count: dice_count,
       roll_mode: roll_mode,
       modifier: modifier
     )}
  end

  def handle_info({:dice_roll, result}, socket) do
    {:noreply, update(socket, :rolls, fn rolls -> [result | Enum.take(rolls, 24)] end)}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-950 p-8 text-white">
      <div class="mx-auto max-w-6xl">
        <.link
          navigate={~p"/dnd"}
          class="mb-8 inline-flex rounded-lg border border-slate-700 bg-slate-900 px-4 py-2 text-slate-200 transition duration-200 hover:-translate-y-1 hover:border-red-500 hover:bg-slate-800 hover:text-white"
        >
          ← Back to D&D Hub
        </.link>

        <h1 class="mb-2 text-5xl font-bold text-red-500">D&D Dice Roller</h1>
        <p class="mb-8 text-slate-300">
          Join the table, roll dice, and everyone on this page sees the result live.
        </p>

        <div class="grid grid-cols-1 gap-8 lg:grid-cols-2">
          <div class="rounded-2xl border border-red-900 bg-slate-900 p-6 shadow-xl">
            <h2 class="mb-4 text-2xl font-bold">Join the Table</h2>

            <form phx-submit="join" class="mb-8 flex gap-3">
              <input
                type="text"
                name="player_name"
                value={@player_name}
                placeholder="Enter player name"
                class="w-full rounded-lg border border-slate-700 bg-slate-800 px-4 py-3 text-white transition duration-200 focus:border-red-500 focus:outline-none focus:ring-2 focus:ring-red-600"
              />

              <button class="rounded-lg bg-red-600 px-6 py-3 font-bold transition duration-200 hover:-translate-y-1 hover:bg-red-700 hover:shadow-lg hover:shadow-red-950 active:translate-y-0">
                Join
              </button>
            </form>

            <h2 class="mb-4 text-2xl font-bold">Roll Dice</h2>

            <form phx-submit="roll" class="space-y-4">
              <div>
                <label class="mb-1 block text-sm text-slate-300">Dice</label>
                <select
                  name="roll[dice_type]"
                  class="w-full rounded-lg border border-slate-700 bg-slate-800 px-4 py-3 text-white transition duration-200 focus:border-red-500 focus:outline-none focus:ring-2 focus:ring-red-600"
                >
                  <%= for dice <- @dice_types do %>
                    <option value={dice} selected={dice == @dice_type}>{dice}</option>
                  <% end %>
                </select>
              </div>

              <div>
                <label class="mb-1 block text-sm text-slate-300">Number of Dice</label>
                <input
                  type="number"
                  name="roll[dice_count]"
                  min="1"
                  max="20"
                  value={@dice_count}
                  class="w-full rounded-lg border border-slate-700 bg-slate-800 px-4 py-3 text-white transition duration-200 focus:border-red-500 focus:outline-none focus:ring-2 focus:ring-red-600"
                />
                <p class="mt-1 text-xs text-slate-400">
                  You can roll up to 20 dice at once.
                </p>
              </div>

              <div>
                <label class="mb-1 block text-sm text-slate-300">Roll Type</label>
                <select
                  name="roll[roll_mode]"
                  class="w-full rounded-lg border border-slate-700 bg-slate-800 px-4 py-3 text-white transition duration-200 focus:border-red-500 focus:outline-none focus:ring-2 focus:ring-red-600"
                >
                  <option value="normal" selected={@roll_mode == "normal"}>Normal</option>
                  <option value="advantage" selected={@roll_mode == "advantage"}>Advantage</option>
                  <option value="disadvantage" selected={@roll_mode == "disadvantage"}>
                    Disadvantage
                  </option>
                </select>
                <p class="mt-1 text-xs text-slate-400">
                  Advantage and disadvantage roll two d20s and choose the higher or lower result.
                </p>
              </div>

              <div>
                <label class="mb-1 block text-sm text-slate-300">Modifier</label>
                <input
                  type="number"
                  name="roll[modifier]"
                  value={@modifier}
                  class="w-full rounded-lg border border-slate-700 bg-slate-800 px-4 py-3 text-white transition duration-200 focus:border-red-500 focus:outline-none focus:ring-2 focus:ring-red-600"
                />
              </div>

              <button class="w-full rounded-xl bg-red-600 px-5 py-4 text-lg font-bold transition duration-200 hover:-translate-y-1 hover:bg-red-700 hover:shadow-xl hover:shadow-red-950 active:translate-y-0">
                Roll
              </button>
            </form>
          </div>

          <div class="rounded-2xl border border-slate-700 bg-slate-900 p-6 shadow-xl">
            <h2 class="mb-4 text-2xl font-bold">Live Roll Log</h2>

            <%= if @rolls == [] do %>
              <p class="text-slate-400">No rolls yet. Be the first adventurer.</p>
            <% else %>
              <div class="space-y-3">
                <%= for roll <- @rolls do %>
                  <%= if roll.type == :join do %>
                    <div class="rounded-xl border border-emerald-800 bg-emerald-950/40 p-4 transition duration-200 hover:-translate-y-1 hover:border-emerald-500">
                      <div class="flex justify-between gap-4">
                        <span class="font-bold text-emerald-300">{roll.message}</span>
                        <span class="text-sm text-slate-400">{roll.time}</span>
                      </div>
                    </div>
                  <% else %>
                    <div class={[
                      "rounded-xl border bg-slate-800 p-4 transition duration-200 hover:-translate-y-1 hover:bg-slate-700",
                      critical_border_class(roll)
                    ]}>
                      <div class="flex justify-between gap-4">
                        <span class="font-bold text-red-400">{roll.player}</span>
                        <span class="text-sm text-slate-400">{roll.time}</span>
                      </div>

                      <p class="mt-2">
                        Rolled <strong>{roll.label}</strong>:
                        <span class="text-slate-200">{format_rolls(roll.raw_rolls)}</span>

                        <%= if roll.roll_mode == "advantage" do %>
                          <span class="ml-2 rounded-full bg-green-900 px-2 py-1 text-xs font-bold text-green-300">
                            advantage chose {roll.chosen_roll}
                          </span>
                        <% end %>

                        <%= if roll.roll_mode == "disadvantage" do %>
                          <span class="ml-2 rounded-full bg-purple-900 px-2 py-1 text-xs font-bold text-purple-300">
                            disadvantage chose {roll.chosen_roll}
                          </span>
                        <% end %>
                      </p>

                      <p class="mt-2">
                        Modifier:
                        <%= if roll.modifier >= 0 do %>
                          + {roll.modifier}
                        <% else %>
                          - {abs(roll.modifier)}
                        <% end %>
                        = <strong class="text-2xl text-yellow-300">{roll.total}</strong>
                      </p>

                      <%= if roll.note do %>
                        <p class={["mt-2 text-sm font-bold", critical_text_class(roll)]}>
                          {roll.note}
                        </p>
                      <% end %>
                    </div>
                  <% end %>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp build_roll_result(%{
         player: player,
         dice_type: "d20",
         dice_count: _dice_count,
         roll_mode: roll_mode,
         modifier: modifier,
         sides: 20
       })
       when roll_mode in ["advantage", "disadvantage"] do
    raw_rolls = [Enum.random(1..20), Enum.random(1..20)]

    chosen_roll =
      case roll_mode do
        "advantage" -> Enum.max(raw_rolls)
        "disadvantage" -> Enum.min(raw_rolls)
      end

    total = chosen_roll + modifier

    %{
      type: :roll,
      player: player,
      dice_type: "d20",
      dice_count: 2,
      roll_mode: roll_mode,
      label: "2d20 with #{roll_mode}",
      raw_rolls: raw_rolls,
      chosen_roll: chosen_roll,
      modifier: modifier,
      total: total,
      note: critical_note(chosen_roll),
      time: current_time()
    }
  end

  defp build_roll_result(%{
         player: player,
         dice_type: dice_type,
         dice_count: dice_count,
         roll_mode: roll_mode,
         modifier: modifier,
         sides: sides
       }) do
    raw_rolls = Enum.map(1..dice_count, fn _ -> Enum.random(1..sides) end)
    raw_total = Enum.sum(raw_rolls)
    total = raw_total + modifier

    %{
      type: :roll,
      player: player,
      dice_type: dice_type,
      dice_count: dice_count,
      roll_mode: roll_mode,
      label: "#{dice_count}#{dice_type}",
      raw_rolls: raw_rolls,
      chosen_roll: raw_total,
      modifier: modifier,
      total: total,
      note: multi_dice_note(dice_type, dice_count, raw_rolls),
      time: current_time()
    }
  end

  defp multi_dice_note("d20", 1, [20]), do: "Natural 20! Critical success."
  defp multi_dice_note("d20", 1, [1]), do: "Natural 1! Critical failure."
  defp multi_dice_note(_, _, _), do: nil

  defp critical_note(20), do: "Natural 20! Critical success."
  defp critical_note(1), do: "Natural 1! Critical failure."
  defp critical_note(_), do: nil

  defp critical_border_class(%{note: "Natural 20! Critical success."}) do
    "border-yellow-500"
  end

  defp critical_border_class(%{note: "Natural 1! Critical failure."}) do
    "border-red-500"
  end

  defp critical_border_class(_roll), do: "border-slate-700"

  defp critical_text_class(%{note: "Natural 20! Critical success."}) do
    "text-yellow-300"
  end

  defp critical_text_class(%{note: "Natural 1! Critical failure."}) do
    "text-red-300"
  end

  defp critical_text_class(_roll), do: "text-slate-300"

  defp format_rolls(rolls) do
    rolls
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join(", ")
  end

  defp current_time do
    Calendar.strftime(DateTime.utc_now(), "%H:%M:%S")
  end

  defp clamp(value, min, _max) when value < min, do: min
  defp clamp(value, _min, max) when value > max, do: max
  defp clamp(value, _min, _max), do: value

  defp parse_int(nil), do: 0
  defp parse_int(""), do: 0
  defp parse_int(value) when is_integer(value), do: value

  defp parse_int(value) do
    case Integer.parse(value) do
      {number, _rest} -> number
      :error -> 0
    end
  end

  defp blank_to_default("", default), do: default
  defp blank_to_default(nil, default), do: default
  defp blank_to_default(value, _default), do: value
end
