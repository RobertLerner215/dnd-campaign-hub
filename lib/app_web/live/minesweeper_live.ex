defmodule AppWeb.MinesweeperLive do
  use AppWeb, :live_view

  alias App.ETS
  alias App.Games.Minesweeper

  @game_fields [:mine_map, :open_map, :last_opened, :finished, :won]

  @impl true
  def mount(params, _session, socket) do
    case Map.get(params, "id") do
      nil ->
        game = ETS.create_game()
        {:ok, push_navigate(socket, to: ~p"/minesweeper/#{game.id}")}

      id ->
        game =
          case ETS.get_game(id) do
            nil -> ETS.create_game()
            existing_game -> existing_game
          end

        {:ok, assign(socket, game: game)}
    end
  end

  @impl true
  def handle_event("new_game", _params, socket) do
    game = ETS.create_game()
    {:noreply, push_navigate(socket, to: ~p"/minesweeper/#{game.id}")}
  end

  @impl true
  def handle_event("open", %{"index" => index}, socket) do
    index = String.to_integer(index)
    game = socket.assigns.game

    updated_game =
      game
      |> Minesweeper.open_field(index)
      |> then(fn new_game ->
        ETS.set_game(new_game.id, Map.take(new_game, @game_fields))
      end)

    {:noreply, assign(socket, game: updated_game)}
  end

  defp opened?(game, index), do: Enum.at(game.open_map, index)
  defp mine?(game, index), do: Enum.at(game.mine_map, index)

  defp show_mine?(game, index) do
    mine?(game, index) and
      (opened?(game, index) or (game.finished and not game.won))
  end

  defp cell_text(game, index) do
    cond do
      show_mine?(game, index) ->
        "💣"

      opened?(game, index) ->
        Minesweeper.adjacent_count(game, index) |> Integer.to_string()

      true ->
        ""
    end
  end

  defp cell_class(game, index) do
    cond do
      show_mine?(game, index) and index == game.last_opened ->
        "w-12 h-12 border border-slate-500 bg-red-600 text-white text-lg font-bold rounded"

      show_mine?(game, index) ->
        "w-12 h-12 border border-slate-500 bg-red-400 text-white text-lg font-bold rounded"

      opened?(game, index) ->
        "w-12 h-12 border border-slate-500 bg-slate-300 text-slate-900 text-lg font-bold rounded"

      true ->
        "w-12 h-12 border border-slate-500 bg-slate-600 hover:bg-slate-500 text-white text-lg font-bold rounded"
    end
  end

  defp status_text(game) do
    cond do
      game.finished and game.won -> "You won"
      game.finished -> "Game over"
      true -> "Game in progress"
    end
  end

  defp status_face(game) do
    cond do
      game.finished and game.won -> "😎"
      game.finished -> "😵"
      true -> "🙂"
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-900 text-white px-6 py-8">
      <div class="max-w-3xl mx-auto">
        <div class="flex items-center justify-between mb-6">
          <h1 class="text-3xl font-bold">Minesweeper</h1>

          <button
            phx-click="new_game"
            class="px-4 py-2 bg-blue-600 hover:bg-blue-500 rounded font-semibold"
          >
            New Game
          </button>
        </div>

        <div class="bg-slate-800 rounded-xl p-6 shadow-lg">
          <div class="flex items-center justify-between mb-6">
            <div>
              <p class="text-sm text-slate-300">Status</p>
              <p class="text-xl font-bold">{status_face(@game)} {status_text(@game)}</p>
            </div>

            <div class="text-right">
              <p class="text-sm text-slate-300">Remaining mines</p>
              <p class="text-2xl font-bold">{Minesweeper.remaining_mines(@game)}</p>
            </div>
          </div>

          <div class="grid grid-cols-9 gap-1 w-fit mx-auto">
            <%= for index <- 0..80 do %>
              <button
                phx-click="open"
                phx-value-index={index}
                disabled={@game.finished or opened?(@game, index)}
                class={cell_class(@game, index)}
              >
                {cell_text(@game, index)}
              </button>
            <% end %>
          </div>

          <div class="mt-6 text-sm text-slate-300">
            <p>Open a square to reveal either a number or a mine.</p>
            <p>If you click a mine, all mines are shown and the game ends.</p>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
