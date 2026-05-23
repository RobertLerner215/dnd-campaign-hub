defmodule AppWeb.DndLive.NoteLive.Form do
  use AppWeb, :live_view

  alias App.Dnd
  alias App.Dnd.Note

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-screen bg-slate-950 text-white">
        <div class="mx-auto max-w-4xl px-6 py-10">
          <.link
            navigate={return_path(@return_to, @note)}
            class="mb-8 inline-flex rounded-lg border border-slate-700 bg-slate-900 px-4 py-2 text-slate-200 transition duration-200 hover:-translate-y-1 hover:border-red-500 hover:bg-slate-800 hover:text-white"
          >
            ← Back
          </.link>

          <div class="mb-8">
            <h1 class="text-5xl font-bold text-red-500">{@page_title}</h1>
            <p class="mt-2 text-slate-300">
              Write campaign notes, private thoughts, shared clues, or DM-only secrets.
            </p>

            <p class="mt-3 text-sm text-slate-400">
              Logged in as <span class="font-bold text-red-300">{@current_user.email}</span>
              <span class="ml-2 rounded-full bg-slate-800 px-3 py-1 text-xs font-bold text-yellow-300">
                {@current_user.role}
              </span>
            </p>
          </div>

          <div class="rounded-2xl border border-red-800 bg-slate-900 p-6 shadow-xl">
            <.form for={@form} id="note-form" phx-change="validate" phx-submit="save">
              <div class="space-y-5">
                <div>
                  <label class="mb-1 block text-sm text-slate-300">Title</label>
                  <input
                    type="text"
                    name="note[title]"
                    value={@form[:title].value}
                    class="w-full rounded-lg border border-slate-700 bg-slate-800 px-4 py-3 text-white transition duration-200 focus:border-red-500 focus:outline-none focus:ring-2 focus:ring-red-600"
                  />
                  <%= for {msg, _opts} <- @form[:title].errors do %>
                    <p class="mt-1 text-sm text-red-300">{msg}</p>
                  <% end %>
                </div>

                <div>
                  <label class="mb-1 block text-sm text-slate-300">Body</label>
                  <textarea
                    name="note[body]"
                    class="min-h-48 w-full rounded-lg border border-slate-700 bg-slate-800 px-4 py-3 text-white transition duration-200 focus:border-red-500 focus:outline-none focus:ring-2 focus:ring-red-600"
                  ><%= @form[:body].value %></textarea>
                  <%= for {msg, _opts} <- @form[:body].errors do %>
                    <p class="mt-1 text-sm text-red-300">{msg}</p>
                  <% end %>
                </div>

                <%= if @current_user.role == "dm" do %>
                  <div>
                    <label class="mb-1 block text-sm text-slate-300">Visibility</label>
                    <select
                      name="note[visibility]"
                      class="w-full rounded-lg border border-slate-700 bg-slate-800 px-4 py-3 text-white transition duration-200 focus:border-red-500 focus:outline-none focus:ring-2 focus:ring-red-600"
                    >
                      <option
                        value="private"
                        selected={selected?(@form[:visibility].value, "private")}
                      >
                        Private to me
                      </option>
                      <option value="shared" selected={selected?(@form[:visibility].value, "shared")}>
                        Shared with players
                      </option>
                      <option
                        value="dm_only"
                        selected={selected?(@form[:visibility].value, "dm_only")}
                      >
                        DM only
                      </option>
                    </select>

                    <p class="mt-2 text-sm text-slate-400">
                      Shared notes can be seen by players. DM-only notes are hidden from players.
                    </p>
                  </div>
                <% else %>
                  <input type="hidden" name="note[visibility]" value="private" />

                  <div class="rounded-xl border border-yellow-700 bg-yellow-950/30 p-4 text-yellow-200">
                    Player notes are private. Only you and the Dungeon Master can see them.
                  </div>
                <% end %>
              </div>

              <footer class="mt-6 flex gap-3">
                <button
                  type="submit"
                  phx-disable-with="Saving..."
                  class="rounded-xl bg-red-600 px-5 py-3 font-bold text-white transition duration-200 hover:-translate-y-1 hover:bg-red-700 hover:shadow-xl hover:shadow-red-950"
                >
                  Save Note
                </button>

                <.link
                  navigate={return_path(@return_to, @note)}
                  class="rounded-xl bg-slate-700 px-5 py-3 font-bold text-white transition duration-200 hover:-translate-y-1 hover:bg-slate-600"
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
    current_user = socket.assigns.current_scope.user

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    current_user = socket.assigns.current_user
    note = Dnd.get_note_for_user!(current_user, id)

    if can_manage_note?(current_user, note) do
      socket
      |> assign(:page_title, "Edit Note")
      |> assign(:note, note)
      |> assign(:form, to_form(Dnd.change_note(note)))
    else
      socket
      |> put_flash(:error, "You are not allowed to edit that note.")
      |> push_navigate(to: ~p"/dnd/notes")
    end
  end

  defp apply_action(socket, :new, _params) do
    visibility =
      if socket.assigns.current_user.role == "dm" do
        "private"
      else
        "private"
      end

    note = %Note{visibility: visibility}

    socket
    |> assign(:page_title, "New Note")
    |> assign(:note, note)
    |> assign(:form, to_form(Dnd.change_note(note)))
  end

  @impl true
  def handle_event("validate", %{"note" => note_params}, socket) do
    changeset = Dnd.change_note(socket.assigns.note, note_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"note" => note_params}, socket) do
    save_note(socket, socket.assigns.live_action, note_params)
  end

  defp save_note(socket, :edit, note_params) do
    current_user = socket.assigns.current_user

    case Dnd.update_note_for_user(current_user, socket.assigns.note, note_params) do
      {:ok, note} ->
        {:noreply,
         socket
         |> put_flash(:info, "Note updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, note))}

      {:error, :not_allowed} ->
        {:noreply,
         socket
         |> put_flash(:error, "You are not allowed to update that note.")
         |> push_navigate(to: ~p"/dnd/notes")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_note(socket, :new, note_params) do
    current_user = socket.assigns.current_user

    case Dnd.create_note_for_user(current_user, note_params) do
      {:ok, note} ->
        {:noreply,
         socket
         |> put_flash(:info, "Note created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, note))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp can_manage_note?(%App.Accounts.User{role: "dm"}, _note), do: true
  defp can_manage_note?(%App.Accounts.User{id: user_id}, %{user_id: user_id}), do: true
  defp can_manage_note?(_user, _note), do: false

  defp selected?(nil, "private"), do: true
  defp selected?(value, value), do: true
  defp selected?(_value, _expected), do: false

  defp return_path("index", _note), do: ~p"/dnd/notes"
  defp return_path("show", note), do: ~p"/dnd/notes/#{note.id}"
end
