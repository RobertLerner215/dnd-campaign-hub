defmodule AppWeb.CharacterLive.Index do
  use AppWeb, :live_view

  alias App.Dnd

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-screen bg-slate-950 text-white">
        <div class="mx-auto max-w-7xl px-6 py-10">
          <.link
            navigate={~p"/dnd"}
            class="mb-8 inline-flex rounded-lg border border-slate-700 bg-slate-900 px-4 py-2 text-slate-200 transition duration-200 hover:-translate-y-1 hover:border-red-500 hover:bg-slate-800 hover:text-white"
          >
            ← Back to D&D Hub
          </.link>

          <div class="mb-8 flex flex-col justify-between gap-4 md:flex-row md:items-center">
            <div>
              <h1 class="text-5xl font-bold text-red-500">D&D Characters</h1>
              <p class="mt-2 text-slate-300">
                View your party, character portraits, stats, and campaign notes.
              </p>
            </div>

            <.link
              navigate={~p"/dnd/characters/new"}
              class="rounded-xl bg-red-600 px-5 py-3 font-bold text-white transition duration-200 hover:-translate-y-1 hover:bg-red-700 hover:shadow-xl hover:shadow-red-950"
            >
              + New Character
            </.link>
          </div>

          <%= if @characters == [] do %>
            <div class="rounded-2xl border border-red-700 bg-slate-900 p-10 text-center">
              <h2 class="text-2xl font-bold text-red-400">No characters yet</h2>
              <p class="mt-2 text-slate-300">
                Create your first adventurer to start building the party.
              </p>
            </div>
          <% else %>
            <div class="grid grid-cols-1 gap-6 md:grid-cols-2 xl:grid-cols-3">
              <%= for character <- @characters do %>
                <article class="overflow-hidden rounded-2xl border border-red-800 bg-slate-900 shadow-xl transition duration-200 hover:-translate-y-1 hover:bg-slate-800 hover:shadow-red-950">
                  <div class="h-80 bg-slate-950">
                    <%= if portrait_url(character.portrait_path) do %>
                      <img
                        src={portrait_url(character.portrait_path)}
                        alt={"Portrait for #{character.name}"}
                        class="h-full w-full object-contain p-3"
                      />
                    <% else %>
                      <div class="flex h-full items-center justify-center text-center text-slate-400">
                        <div>
                          <p class="text-5xl">🎲</p>
                          <p class="mt-2 text-sm">No portrait</p>
                        </div>
                      </div>
                    <% end %>
                  </div>

                  <div class="p-6">
                    <div class="mb-4 flex items-start justify-between gap-4">
                      <div>
                        <h2 class="text-2xl font-bold text-red-400">{character.name}</h2>
                        <p class="mt-1 text-slate-300">
                          Level {character.level} {blank_default(character.race, "Unknown Race")}
                          {blank_default(character.class, "Adventurer")}
                        </p>
                      </div>

                      <span class="rounded-full bg-slate-800 px-3 py-1 text-sm font-bold text-yellow-300">
                        AC {character.armor_class}
                      </span>
                    </div>

                    <div class="grid grid-cols-3 gap-3 text-center">
                      <div class="rounded-xl bg-slate-950 p-3">
                        <p class="text-xs text-slate-400">HP</p>
                        <p class="text-xl font-bold text-emerald-300">{character.hp}</p>
                      </div>

                      <div class="rounded-xl bg-slate-950 p-3">
                        <p class="text-xs text-slate-400">STR</p>
                        <p class="text-xl font-bold">{character.strength}</p>
                      </div>

                      <div class="rounded-xl bg-slate-950 p-3">
                        <p class="text-xs text-slate-400">DEX</p>
                        <p class="text-xl font-bold">{character.dexterity}</p>
                      </div>
                    </div>

                    <p class="mt-4 line-clamp-3 text-sm text-slate-300">
                      {blank_default(character.notes, "No notes yet.")}
                    </p>

                    <div class="mt-5 flex flex-wrap gap-3">
                      <.link
                        navigate={~p"/dnd/characters/#{character.id}"}
                        class="rounded-lg bg-slate-700 px-4 py-2 font-bold text-white transition hover:bg-slate-600"
                      >
                        Open
                      </.link>

                      <.link
                        navigate={~p"/dnd/characters/#{character.id}/edit"}
                        class="rounded-lg bg-blue-600 px-4 py-2 font-bold text-white transition hover:bg-blue-700"
                      >
                        Edit
                      </.link>

                      <button
                        phx-click="delete"
                        phx-value-id={character.id}
                        data-confirm="Delete this character?"
                        class="rounded-lg bg-red-600 px-4 py-2 font-bold text-white transition hover:bg-red-700"
                      >
                        Delete
                      </button>
                    </div>
                  </div>
                </article>
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
    if connected?(socket), do: Dnd.subscribe_characters()

    {:ok,
     socket
     |> assign(:page_title, "D&D Characters")
     |> assign(:characters, Dnd.list_characters())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    character = Dnd.get_character!(id)
    {:ok, _} = Dnd.delete_character(character)

    {:noreply, assign(socket, :characters, Dnd.list_characters())}
  end

  @impl true
  def handle_info({_type, %App.Dnd.Character{}}, socket) do
    {:noreply, assign(socket, :characters, Dnd.list_characters())}
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
