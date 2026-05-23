defmodule AppWeb.RockPaperScissorsLive do
  use AppWeb, :live_view

  @table :rps_games

  @impl true
  def mount(params, _session, socket) do
    ensure_table()

    case Map.get(params, "id") do
      nil ->
        game_id = Ecto.UUID.generate()

        {:ok,
         push_navigate(
           socket,
           to: ~p"/rock-paper-scissors/#{game_id}?player=1"
         )}

      game_id ->
        player =
          case Map.get(params, "player", "1") do
            "2" -> 2
            _ -> 1
          end

        if connected?(socket) do
          Phoenix.PubSub.subscribe(App.PubSub, topic(game_id))
        end

        game = get_game(game_id)

        {:ok,
         assign(socket,
           game_id: game_id,
           player: player,
           p1: game.p1,
           p2: game.p2,
           score1: game.score1,
           score2: game.score2,
           result: game.result
         )}
    end
  end

  @impl true
  def handle_event("pick", %{"choice" => choice}, socket) do
    game = get_game(socket.assigns.game_id)

    game =
      case socket.assigns.player do
        1 -> %{game | p1: choice}
        2 -> %{game | p2: choice}
      end

    game =
      if game.p1 && game.p2 do
        resolve_round(game)
      else
        game
      end

    save_game(socket.assigns.game_id, game)

    Phoenix.PubSub.broadcast(
      App.PubSub,
      topic(socket.assigns.game_id),
      {:update, game}
    )

    {:noreply,
     assign(socket,
       p1: game.p1,
       p2: game.p2,
       score1: game.score1,
       score2: game.score2,
       result: game.result
     )}
  end

  @impl true
  def handle_info({:update, game}, socket) do
    {:noreply,
     assign(socket,
       p1: game.p1,
       p2: game.p2,
       score1: game.score1,
       score2: game.score2,
       result: game.result
     )}
  end

  defp resolve_round(game) do
    cond do
      game.p1 == game.p2 ->
        %{game | result: "Tie! #{game.p1} = #{game.p2}", p1: nil, p2: nil}

      win?(game.p1, game.p2) ->
        %{
          game
          | score1: game.score1 + 1,
            result: "Player 1 wins! #{game.p1} beats #{game.p2}",
            p1: nil,
            p2: nil
        }

      true ->
        %{
          game
          | score2: game.score2 + 1,
            result: "Player 2 wins! #{game.p2} beats #{game.p1}",
            p1: nil,
            p2: nil
        }
    end
  end

  defp win?("rock", "scissors"), do: true
  defp win?("paper", "rock"), do: true
  defp win?("scissors", "paper"), do: true
  defp win?(_, _), do: false

  defp ensure_table do
    if :ets.whereis(@table) == :undefined do
      :ets.new(@table, [:named_table, :public, :set])
    end
  end

  defp topic(game_id), do: "rps:#{game_id}"

  defp default_game do
    %{
      p1: nil,
      p2: nil,
      score1: 0,
      score2: 0,
      result: "Waiting for moves..."
    }
  end

  defp get_game(game_id) do
    case :ets.lookup(@table, game_id) do
      [{^game_id, game}] -> game
      [] -> default_game()
    end
  end

  defp save_game(game_id, game) do
    :ets.insert(@table, {game_id, game})
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto text-center text-white p-10">
      <h1 class="text-5xl font-bold mb-6">Rock Paper Scissors</h1>

      <p class="text-xl mb-2">Open one tab for each player:</p>

      <p class="mb-2">
        <a
          href={~p"/rock-paper-scissors/#{@game_id}?player=1"}
          target="_blank"
          class="text-blue-400 underline"
        >
          Player 1 Link
        </a>
      </p>

      <p class="mb-6">
        <a
          href={~p"/rock-paper-scissors/#{@game_id}?player=2"}
          target="_blank"
          class="text-green-400 underline"
        >
          Player 2 Link
        </a>
      </p>

      <p class="text-xl mb-4">
        You are Player {@player}
      </p>

      <div class="text-2xl mb-3">
        Player 1: {@score1} |
        Player 2: {@score2}
      </div>

      <div class="text-green-400 text-xl mb-8">
        {@result}
      </div>

      <p class="mb-3">
        Selected:
        Player1 = {@p1 || "None"},
        Player2 = {@p2 || "None"}
      </p>

      <button phx-click="pick" phx-value-choice="rock" class="btn btn-primary m-1">
        🪨 Rock
      </button>

      <button phx-click="pick" phx-value-choice="paper" class="btn btn-primary m-1">
        📄 Paper
      </button>

      <button phx-click="pick" phx-value-choice="scissors" class="btn btn-primary m-1">
        ✂️ Scissors
      </button>
    </div>
    """
  end
end
