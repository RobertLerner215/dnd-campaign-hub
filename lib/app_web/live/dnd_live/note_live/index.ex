defmodule AppWeb.DndLive.NoteLive.Index do
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
              <h1 class="text-5xl font-bold text-red-500">Campaign Journal</h1>
              <p class="mt-2 text-slate-300">
                Save private notes, shared clues, DM secrets, lore, and session reminders.
              </p>

              <p class="mt-3 text-sm text-slate-400">
                Logged in as <span class="font-bold text-red-300">{@current_user.email}</span>
                <span class="ml-2 rounded-full bg-slate-800 px-3 py-1 text-xs font-bold text-yellow-300">
                  {@current_user.role}
                </span>
              </p>
            </div>

            <.link
              navigate={~p"/dnd/notes/new"}
              class="rounded-xl bg-red-600 px-5 py-3 font-bold text-white transition duration-200 hover:-translate-y-1 hover:bg-red-700 hover:shadow-xl hover:shadow-red-950"
            >
              + New Note
            </.link>
          </div>

          <%= if Enum.empty?(@notes) do %>
            <div class="rounded-2xl border border-red-700 bg-slate-900 p-10 text-center">
              <h2 class="text-2xl font-bold text-red-400">No notes visible</h2>
              <p class="mt-2 text-slate-300">
                Create your first note, or ask the DM to make a shared note.
              </p>
            </div>
          <% else %>
            <div class="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
              <%= for note <- @notes do %>
                <div class="rounded-2xl border border-red-700 bg-slate-900 p-6 shadow-lg transition duration-200 hover:-translate-y-1 hover:bg-slate-800 hover:shadow-xl hover:shadow-red-950">
                  <div class="mb-3 flex items-start justify-between gap-3">
                    <h2 class="text-2xl font-bold text-red-400">{note.title}</h2>

                    <span class={[
                      "rounded-full px-3 py-1 text-xs font-bold",
                      visibility_class(note.visibility)
                    ]}>
                      {visibility_label(note.visibility)}
                    </span>
                  </div>

                  <p class="mt-3 line-clamp-5 whitespace-pre-wrap text-slate-300">
                    {note.body}
                  </p>

                  <p class="mt-4 text-xs text-slate-500">
                    {owner_label(note, @current_user)}
                  </p>

                  <div class="mt-6 flex flex-wrap gap-3">
                    <.link
                      navigate={~p"/dnd/notes/#{note.id}"}
                      class="rounded-lg bg-slate-700 px-4 py-2 font-bold text-white transition hover:bg-slate-600"
                    >
                      Open
                    </.link>

                    <%= if can_manage_note?(@current_user, note) do %>
                      <.link
                        navigate={~p"/dnd/notes/#{note.id}/edit"}
                        class="rounded-lg bg-blue-600 px-4 py-2 font-bold text-white transition hover:bg-blue-700"
                      >
                        Edit
                      </.link>

                      <button
                        phx-click="delete"
                        phx-value-id={note.id}
                        data-confirm="Delete this note?"
                        class="rounded-lg bg-red-600 px-4 py-2 font-bold text-white transition hover:bg-red-700"
                      >
                        Delete
                      </button>
                    <% end %>
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
    if connected?(socket), do: Dnd.subscribe_notes()

    current_user = current_user(socket)

    {:ok,
     socket
     |> assign(:page_title, "D&D Notes")
     |> assign(:current_user, current_user)
     |> assign(:notes, Dnd.list_notes_for_user(current_user))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    current_user = socket.assigns.current_user
    note = Dnd.get_note_for_user!(current_user, id)

    case Dnd.delete_note_for_user(current_user, note) do
      {:ok, _note} ->
        {:noreply, assign(socket, :notes, Dnd.list_notes_for_user(current_user))}

      {:error, :not_allowed} ->
        {:noreply,
         socket
         |> put_flash(:error, "You are not allowed to delete that note.")
         |> assign(:notes, Dnd.list_notes_for_user(current_user))}
    end
  end

  @impl true
  def handle_info({type, %App.Dnd.Note{}}, socket)
      when type in [:created, :updated, :deleted] do
    current_user = socket.assigns.current_user
    {:noreply, assign(socket, :notes, Dnd.list_notes_for_user(current_user))}
  end

  def handle_info(_message, socket) do
    {:noreply, socket}
  end

  defp current_user(socket), do: socket.assigns.current_scope.user

  defp can_manage_note?(%App.Accounts.User{role: "dm"}, _note), do: true
  defp can_manage_note?(%App.Accounts.User{id: user_id}, %{user_id: user_id}), do: true
  defp can_manage_note?(_user, _note), do: false

  defp visibility_label("shared"), do: "Shared"
  defp visibility_label("dm_only"), do: "DM Only"
  defp visibility_label("private"), do: "Private"
  defp visibility_label(_), do: "Private"

  defp visibility_class("shared"), do: "bg-emerald-900 text-emerald-300"
  defp visibility_class("dm_only"), do: "bg-red-950 text-red-300"
  defp visibility_class("private"), do: "bg-slate-800 text-yellow-300"
  defp visibility_class(_), do: "bg-slate-800 text-yellow-300"

  defp owner_label(note, %App.Accounts.User{id: user_id}) do
    cond do
      is_nil(note.user_id) -> "Created before user ownership was added"
      note.user_id == user_id -> "Created by you"
      true -> "Created by another user"
    end
  end
end
