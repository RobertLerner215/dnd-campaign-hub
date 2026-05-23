defmodule AppWeb.DndLive.NoteLive.Show do
  use AppWeb, :live_view

  alias App.Dnd

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-screen bg-slate-950 text-white">
        <div class="mx-auto max-w-4xl px-6 py-10">
          <.link
            navigate={~p"/dnd/notes"}
            class="mb-8 inline-flex rounded-lg border border-slate-700 bg-slate-900 px-4 py-2 text-slate-200 transition duration-200 hover:-translate-y-1 hover:border-red-500 hover:bg-slate-800 hover:text-white"
          >
            ← Back to Notes
          </.link>

          <div class="rounded-2xl border border-red-800 bg-slate-900 p-6 shadow-xl">
            <div class="mb-6 flex flex-col justify-between gap-4 md:flex-row md:items-start">
              <div>
                <div class="mb-3">
                  <span class={[
                    "rounded-full px-3 py-1 text-xs font-bold",
                    visibility_class(@note.visibility)
                  ]}>
                    {visibility_label(@note.visibility)}
                  </span>
                </div>

                <h1 class="text-5xl font-bold text-red-500">{@note.title}</h1>
                <p class="mt-2 text-slate-400">
                  {owner_label(@note, @current_user)}
                </p>
              </div>

              <%= if @can_manage_note do %>
                <.link
                  navigate={~p"/dnd/notes/#{@note.id}/edit?return_to=show"}
                  class="rounded-xl bg-red-600 px-5 py-3 font-bold text-white transition duration-200 hover:-translate-y-1 hover:bg-red-700 hover:shadow-xl hover:shadow-red-950"
                >
                  Edit Note
                </.link>
              <% end %>
            </div>

            <div class="rounded-xl border border-slate-700 bg-slate-950 p-6">
              <p class="whitespace-pre-wrap text-lg leading-8 text-slate-200">{@note.body}</p>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket), do: Dnd.subscribe_notes()

    current_user = socket.assigns.current_scope.user
    note = Dnd.get_note_for_user!(current_user, id)

    {:ok,
     socket
     |> assign(:page_title, "Show Note")
     |> assign(:current_user, current_user)
     |> assign(:note, note)
     |> assign(:can_manage_note, can_manage_note?(current_user, note))}
  end

  @impl true
  def handle_info(
        {:updated, %App.Dnd.Note{id: id} = note},
        %{assigns: %{note: %{id: id}, current_user: current_user}} = socket
      ) do
    if can_view_note?(current_user, note) do
      {:noreply,
       socket
       |> assign(:note, note)
       |> assign(:can_manage_note, can_manage_note?(current_user, note))}
    else
      {:noreply,
       socket
       |> put_flash(:error, "You no longer have access to that note.")
       |> push_navigate(to: ~p"/dnd/notes")}
    end
  end

  def handle_info(
        {:deleted, %App.Dnd.Note{id: id}},
        %{assigns: %{note: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current note was deleted.")
     |> push_navigate(to: ~p"/dnd/notes")}
  end

  def handle_info({type, %App.Dnd.Note{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end

  def handle_info(_message, socket) do
    {:noreply, socket}
  end

  defp can_view_note?(%App.Accounts.User{role: "dm"}, _note), do: true
  defp can_view_note?(_user, %{visibility: "shared"}), do: true
  defp can_view_note?(%App.Accounts.User{id: user_id}, %{user_id: user_id}), do: true
  defp can_view_note?(_user, _note), do: false

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
