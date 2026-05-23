defmodule AppWeb.DndLive.Quests do
  use AppWeb, :live_view

  alias App.Dnd
  alias App.Dnd.Quest

  @statuses [
    {"available", "Available"},
    {"in_progress", "In Progress"},
    {"completed", "Completed"},
    {"failed", "Failed"}
  ]

  @difficulties ["easy", "medium", "hard", "deadly"]

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Dnd.subscribe_quests()

    {:ok,
     socket
     |> assign(:page_title, "Quest Board")
     |> assign(:statuses, @statuses)
     |> assign(:difficulties, @difficulties)
     |> assign(:quests, Dnd.list_quests())
     |> assign(:form, to_form(Dnd.change_quest(%Quest{})))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-950 p-8 text-white">
      <div class="mx-auto max-w-7xl">
        <.link
          navigate={~p"/dnd"}
          class="mb-8 inline-flex rounded-lg border border-slate-700 bg-slate-900 px-4 py-2 text-slate-200 transition duration-200 hover:-translate-y-1 hover:border-red-500 hover:bg-slate-800 hover:text-white"
        >
          ← Back to D&D Hub
        </.link>

        <div class="mb-8">
          <h1 class="text-5xl font-bold text-red-500">Quest Board</h1>
          <p class="mt-2 text-slate-300">
            Track campaign quests, rewards, deadlines, and party progress.
          </p>
        </div>

        <div class="grid grid-cols-1 gap-8 xl:grid-cols-[360px_1fr]">
          <section class="rounded-2xl border border-red-800 bg-slate-900 p-6 shadow-xl">
            <h2 class="mb-4 text-2xl font-bold text-red-400">Add Quest</h2>

            <.form
              for={@form}
              id="quest-form"
              phx-change="validate"
              phx-submit="save"
              class="space-y-4"
            >
              <div>
                <label class="mb-1 block text-sm text-slate-300">Title</label>
                <input
                  type="text"
                  name="quest[title]"
                  value={@form[:title].value}
                  placeholder="Clear the Goblin Cave"
                  class="w-full rounded-lg border border-slate-700 bg-slate-800 px-4 py-3 text-white transition duration-200 focus:border-red-500 focus:outline-none focus:ring-2 focus:ring-red-600"
                />

                <%= for {msg, _opts} <- @form[:title].errors do %>
                  <p class="mt-1 text-sm text-red-300">{msg}</p>
                <% end %>
              </div>

              <div>
                <label class="mb-1 block text-sm text-slate-300">Quest Giver</label>
                <input
                  type="text"
                  name="quest[giver]"
                  value={@form[:giver].value}
                  placeholder="Village Elder"
                  class="w-full rounded-lg border border-slate-700 bg-slate-800 px-4 py-3 text-white transition duration-200 focus:border-red-500 focus:outline-none focus:ring-2 focus:ring-red-600"
                />
              </div>

              <div>
                <label class="mb-1 block text-sm text-slate-300">Location</label>
                <input
                  type="text"
                  name="quest[location]"
                  value={@form[:location].value}
                  placeholder="Blackpine Forest"
                  class="w-full rounded-lg border border-slate-700 bg-slate-800 px-4 py-3 text-white transition duration-200 focus:border-red-500 focus:outline-none focus:ring-2 focus:ring-red-600"
                />
              </div>

              <div>
                <label class="mb-1 block text-sm text-slate-300">Reward</label>
                <input
                  type="text"
                  name="quest[reward]"
                  value={@form[:reward].value}
                  placeholder="Potion of Healing, 50 gold..."
                  class="w-full rounded-lg border border-slate-700 bg-slate-800 px-4 py-3 text-white transition duration-200 focus:border-red-500 focus:outline-none focus:ring-2 focus:ring-red-600"
                />
              </div>

              <div>
                <label class="mb-1 block text-sm text-slate-300">Difficulty</label>
                <select
                  name="quest[difficulty]"
                  class="w-full rounded-lg border border-slate-700 bg-slate-800 px-4 py-3 text-white transition duration-200 focus:border-red-500 focus:outline-none focus:ring-2 focus:ring-red-600"
                >
                  <%= for difficulty <- @difficulties do %>
                    <option value={difficulty} selected={difficulty == selected_difficulty(@form)}>
                      {String.capitalize(difficulty)}
                    </option>
                  <% end %>
                </select>
              </div>

              <div>
                <label class="mb-1 block text-sm text-slate-300">Due Date</label>
                <input
                  type="date"
                  name="quest[due_date]"
                  value={@form[:due_date].value}
                  class="w-full rounded-lg border border-slate-700 bg-slate-800 px-4 py-3 text-white transition duration-200 focus:border-red-500 focus:outline-none focus:ring-2 focus:ring-red-600"
                />
              </div>

              <div>
                <label class="mb-1 block text-sm text-slate-300">Description</label>
                <textarea
                  name="quest[description]"
                  placeholder="What does the party need to do?"
                  class="min-h-28 w-full rounded-lg border border-slate-700 bg-slate-800 px-4 py-3 text-white transition duration-200 focus:border-red-500 focus:outline-none focus:ring-2 focus:ring-red-600"
                ><%= @form[:description].value %></textarea>
              </div>

              <input type="hidden" name="quest[status]" value="available" />

              <button class="w-full rounded-xl bg-red-600 px-5 py-4 text-lg font-bold transition duration-200 hover:-translate-y-1 hover:bg-red-700 hover:shadow-xl hover:shadow-red-950 active:translate-y-0">
                Add Quest
              </button>
            </.form>
          </section>

          <section>
            <div class="mb-4 grid grid-cols-2 gap-4 lg:grid-cols-4">
              <div class="rounded-xl border border-slate-700 bg-slate-900 p-4">
                <p class="text-sm text-slate-400">Total Quests</p>
                <p class="text-3xl font-bold text-white">{length(@quests)}</p>
              </div>

              <div class="rounded-xl border border-slate-700 bg-slate-900 p-4">
                <p class="text-sm text-slate-400">Active</p>
                <p class="text-3xl font-bold text-yellow-300">
                  {count_status(@quests, "in_progress")}
                </p>
              </div>

              <div class="rounded-xl border border-slate-700 bg-slate-900 p-4">
                <p class="text-sm text-slate-400">Completed</p>
                <p class="text-3xl font-bold text-emerald-300">
                  {count_status(@quests, "completed")}
                </p>
              </div>

              <div class="rounded-xl border border-slate-700 bg-slate-900 p-4">
                <p class="text-sm text-slate-400">Failed</p>
                <p class="text-3xl font-bold text-red-300">
                  {count_status(@quests, "failed")}
                </p>
              </div>
            </div>

            <div class="grid grid-cols-1 gap-4 lg:grid-cols-2 2xl:grid-cols-4">
              <%= for {status, label} <- @statuses do %>
                <div class="rounded-2xl border border-slate-700 bg-slate-900 p-4 shadow-xl">
                  <div class="mb-4 flex items-center justify-between">
                    <h2 class={["text-xl font-bold", status_title_class(status)]}>
                      {label}
                    </h2>

                    <span class="rounded-full bg-slate-800 px-3 py-1 text-sm font-bold text-slate-300">
                      {count_status(@quests, status)}
                    </span>
                  </div>

                  <div class="space-y-4">
                    <%= for quest <- quests_for_status(@quests, status) do %>
                      <article class={[
                        "rounded-xl border bg-slate-800 p-4 transition duration-200 hover:-translate-y-1 hover:bg-slate-700",
                        status_border_class(quest.status)
                      ]}>
                        <div class="mb-3 flex items-start justify-between gap-3">
                          <div>
                            <h3 class="text-lg font-bold text-white">{quest.title}</h3>
                            <p class="text-sm text-slate-400">
                              {blank_default(quest.location, "Unknown location")}
                            </p>
                          </div>

                          <span class={[
                            "rounded-full px-2 py-1 text-xs font-bold",
                            difficulty_class(quest.difficulty)
                          ]}>
                            {String.capitalize(quest.difficulty)}
                          </span>
                        </div>

                        <p class="text-sm text-slate-300">
                          <span class="font-bold text-slate-100">Giver:</span>
                          {blank_default(quest.giver, "Unknown")}
                        </p>

                        <p class="mt-1 text-sm text-slate-300">
                          <span class="font-bold text-slate-100">Reward:</span>
                          {blank_default(quest.reward, "No reward listed")}
                        </p>

                        <p class={["mt-2 text-sm font-bold", due_date_class(quest)]}>
                          {due_date_text(quest)}
                        </p>

                        <%= if quest.description && String.trim(quest.description) != "" do %>
                          <p class="mt-3 whitespace-pre-wrap text-sm text-slate-300">
                            {quest.description}
                          </p>
                        <% end %>

                        <div class="mt-4 flex flex-wrap gap-2">
                          <button
                            :if={quest.status != "available"}
                            phx-click="set_status"
                            phx-value-id={quest.id}
                            phx-value-status="available"
                            class="rounded-lg bg-slate-700 px-3 py-2 text-sm font-bold text-white transition hover:bg-slate-600"
                          >
                            Reopen
                          </button>

                          <button
                            :if={quest.status != "in_progress"}
                            phx-click="set_status"
                            phx-value-id={quest.id}
                            phx-value-status="in_progress"
                            class="rounded-lg bg-yellow-600 px-3 py-2 text-sm font-bold text-white transition hover:bg-yellow-700"
                          >
                            Start
                          </button>

                          <button
                            :if={quest.status != "completed"}
                            phx-click="set_status"
                            phx-value-id={quest.id}
                            phx-value-status="completed"
                            class="rounded-lg bg-emerald-600 px-3 py-2 text-sm font-bold text-white transition hover:bg-emerald-700"
                          >
                            Complete
                          </button>

                          <button
                            :if={quest.status != "failed"}
                            phx-click="set_status"
                            phx-value-id={quest.id}
                            phx-value-status="failed"
                            class="rounded-lg bg-red-600 px-3 py-2 text-sm font-bold text-white transition hover:bg-red-700"
                          >
                            Fail
                          </button>

                          <button
                            :if={quest.reward && String.trim(quest.reward) != ""}
                            phx-click="add_reward"
                            phx-value-id={quest.id}
                            class="rounded-lg bg-blue-600 px-3 py-2 text-sm font-bold text-white transition hover:bg-blue-700"
                          >
                            Add Reward
                          </button>

                          <button
                            phx-click="delete"
                            phx-value-id={quest.id}
                            data-confirm="Delete this quest?"
                            class="rounded-lg bg-slate-950 px-3 py-2 text-sm font-bold text-red-300 transition hover:bg-red-950"
                          >
                            Delete
                          </button>
                        </div>
                      </article>
                    <% end %>

                    <%= if quests_for_status(@quests, status) == [] do %>
                      <div class="rounded-xl border border-dashed border-slate-700 p-6 text-center text-sm text-slate-400">
                        No quests here yet.
                      </div>
                    <% end %>
                  </div>
                </div>
              <% end %>
            </div>
          </section>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"quest" => quest_params}, socket) do
    changeset =
      %Quest{}
      |> Dnd.change_quest(quest_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("save", %{"quest" => quest_params}, socket) do
    case Dnd.create_quest(quest_params) do
      {:ok, _quest} ->
        {:noreply,
         socket
         |> put_flash(:info, "Quest added to the board.")
         |> assign(:quests, Dnd.list_quests())
         |> assign(:form, to_form(Dnd.change_quest(%Quest{})))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("set_status", %{"id" => id, "status" => status}, socket) do
    quest = Dnd.get_quest!(id)
    {:ok, _quest} = Dnd.update_quest_status(quest, status)

    {:noreply, assign(socket, :quests, Dnd.list_quests())}
  end

  def handle_event("add_reward", %{"id" => id}, socket) do
    quest = Dnd.get_quest!(id)

    case Dnd.add_quest_reward_to_inventory(quest) do
      {:ok, _item} ->
        {:noreply,
         socket
         |> put_flash(:info, "Quest reward added to inventory.")
         |> assign(:quests, Dnd.list_quests())}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Could not add reward to inventory.")
         |> assign(:quests, Dnd.list_quests())}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    quest = Dnd.get_quest!(id)
    {:ok, _quest} = Dnd.delete_quest(quest)

    {:noreply,
     socket
     |> put_flash(:info, "Quest deleted.")
     |> assign(:quests, Dnd.list_quests())}
  end

  @impl true
  def handle_info({_type, _quest}, socket) do
    {:noreply, assign(socket, :quests, Dnd.list_quests())}
  end

  defp selected_difficulty(form) do
    form[:difficulty].value || "medium"
  end

  defp quests_for_status(quests, status) do
    Enum.filter(quests, &(&1.status == status))
  end

  defp count_status(quests, status) do
    quests
    |> quests_for_status(status)
    |> length()
  end

  defp blank_default(nil, default), do: default

  defp blank_default(value, default) when is_binary(value) do
    if String.trim(value) == "" do
      default
    else
      value
    end
  end

  defp due_date_text(%{due_date: nil}), do: "No due date"

  defp due_date_text(%{due_date: due_date, status: "completed"}) do
    "Completed quest, due date was #{Calendar.strftime(due_date, "%b %d, %Y")}"
  end

  defp due_date_text(%{due_date: due_date, status: "failed"}) do
    "Failed quest, due date was #{Calendar.strftime(due_date, "%b %d, %Y")}"
  end

  defp due_date_text(%{due_date: due_date}) do
    today = Date.utc_today()
    days = Date.diff(due_date, today)
    date = Calendar.strftime(due_date, "%b %d, %Y")

    cond do
      days < 0 -> "Overdue by #{abs(days)} day(s), due #{date}"
      days == 0 -> "Due today"
      days == 1 -> "Due tomorrow"
      true -> "Due in #{days} days, #{date}"
    end
  end

  defp due_date_class(%{due_date: nil}), do: "text-slate-400"
  defp due_date_class(%{status: "completed"}), do: "text-emerald-300"
  defp due_date_class(%{status: "failed"}), do: "text-red-300"

  defp due_date_class(%{due_date: due_date}) do
    today = Date.utc_today()

    if Date.compare(due_date, today) == :lt do
      "text-red-300"
    else
      "text-yellow-300"
    end
  end

  defp status_title_class("available"), do: "text-slate-200"
  defp status_title_class("in_progress"), do: "text-yellow-300"
  defp status_title_class("completed"), do: "text-emerald-300"
  defp status_title_class("failed"), do: "text-red-300"

  defp status_border_class("available"), do: "border-slate-700"
  defp status_border_class("in_progress"), do: "border-yellow-600"
  defp status_border_class("completed"), do: "border-emerald-600"
  defp status_border_class("failed"), do: "border-red-600"

  defp difficulty_class("easy"), do: "bg-emerald-950 text-emerald-300"
  defp difficulty_class("medium"), do: "bg-blue-950 text-blue-300"
  defp difficulty_class("hard"), do: "bg-yellow-950 text-yellow-300"
  defp difficulty_class("deadly"), do: "bg-red-950 text-red-300"
  defp difficulty_class(_), do: "bg-slate-800 text-slate-300"
end
