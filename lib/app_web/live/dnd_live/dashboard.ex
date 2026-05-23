defmodule AppWeb.DndLive.Dashboard do
  use AppWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-950 text-white">
      <div class="mx-auto max-w-6xl px-8 py-10">
        <.link
          navigate={~p"/"}
          class="mb-8 inline-block rounded-lg border border-slate-700 px-4 py-2 text-slate-300 transition duration-200 hover:-translate-y-1 hover:bg-slate-800 hover:text-white"
        >
          ← Back to Robert Site
        </.link>

        <div class="mb-10">
          <h1 class="text-5xl font-bold text-red-500">D&D Campaign Hub</h1>
          <p class="mt-3 text-lg text-slate-300">
            Manage your party, roll dice, track encounters, and organize your campaign.
          </p>
        </div>

        <div class="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
          <.link
            navigate={~p"/dnd/dice"}
            class="rounded-2xl border border-red-700 bg-slate-900 p-6 transition duration-200 hover:-translate-y-1 hover:bg-slate-800 hover:shadow-xl hover:shadow-red-950"
          >
            <h2 class="text-2xl font-bold text-red-400">Dice Roller</h2>
            <p class="mt-2 text-slate-300">Roll dice live with everyone in the session.</p>
          </.link>

          <.link
            navigate={~p"/dnd/characters"}
            class="rounded-2xl border border-red-700 bg-slate-900 p-6 transition duration-200 hover:-translate-y-1 hover:bg-slate-800 hover:shadow-xl hover:shadow-red-950"
          >
            <h2 class="text-2xl font-bold text-red-400">Characters</h2>
            <p class="mt-2 text-slate-300">Create, edit, and view character sheets.</p>
          </.link>

          <.link
            navigate={~p"/dnd/initiative"}
            class="rounded-2xl border border-red-700 bg-slate-900 p-6 transition duration-200 hover:-translate-y-1 hover:bg-slate-800 hover:shadow-xl hover:shadow-red-950"
          >
            <h2 class="text-2xl font-bold text-red-400">Initiative Tracker</h2>
            <p class="mt-2 text-slate-300">Track combat order during encounters.</p>
          </.link>

          <.link
            navigate={~p"/dnd/inventory"}
            class="rounded-2xl border border-red-700 bg-slate-900 p-6 transition duration-200 hover:-translate-y-1 hover:bg-slate-800 hover:shadow-xl hover:shadow-red-950"
          >
            <h2 class="text-2xl font-bold text-red-400">Inventory</h2>
            <p class="mt-2 text-slate-300">Store items, weapons, treasure, and gear.</p>
          </.link>

          <.link
            navigate={~p"/dnd/quests"}
            class="rounded-2xl border border-red-700 bg-slate-900 p-6 transition duration-200 hover:-translate-y-1 hover:bg-slate-800 hover:shadow-xl hover:shadow-red-950"
          >
            <h2 class="text-2xl font-bold text-red-400">Quest Board</h2>
            <p class="mt-2 text-slate-300">
              Track quests, rewards, deadlines, and campaign progress.
            </p>
          </.link>

          <.link
            navigate={~p"/dnd/notes"}
            class="rounded-2xl border border-red-700 bg-slate-900 p-6 transition duration-200 hover:-translate-y-1 hover:bg-slate-800 hover:shadow-xl hover:shadow-red-950"
          >
            <h2 class="text-2xl font-bold text-red-400">Notes</h2>
            <p class="mt-2 text-slate-300">Write campaign notes and session reminders.</p>
          </.link>
        </div>
      </div>
    </div>
    """
  end
end
