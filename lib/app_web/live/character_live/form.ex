defmodule AppWeb.CharacterLive.Form do
  use AppWeb, :live_view

  alias App.Characters
  alias App.Characters.Character

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage character records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="character-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:race]} type="text" label="Race" />
        <.input field={@form[:class]} type="text" label="Class" />
        <.input field={@form[:level]} type="number" label="Level" />
        <.input field={@form[:hp]} type="number" label="Hp" />
        <.input field={@form[:armor_class]} type="number" label="Armor class" />
        <.input field={@form[:notes]} type="textarea" label="Notes" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Character</.button>
          <.button navigate={return_path(@current_scope, @return_to, @character)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    character = Characters.get_character!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Character")
    |> assign(:character, character)
    |> assign(:form, to_form(Characters.change_character(socket.assigns.current_scope, character)))
  end

  defp apply_action(socket, :new, _params) do
    character = %Character{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Character")
    |> assign(:character, character)
    |> assign(:form, to_form(Characters.change_character(socket.assigns.current_scope, character)))
  end

  @impl true
  def handle_event("validate", %{"character" => character_params}, socket) do
    changeset = Characters.change_character(socket.assigns.current_scope, socket.assigns.character, character_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"character" => character_params}, socket) do
    save_character(socket, socket.assigns.live_action, character_params)
  end

  defp save_character(socket, :edit, character_params) do
    case Characters.update_character(socket.assigns.current_scope, socket.assigns.character, character_params) do
      {:ok, character} ->
        {:noreply,
         socket
         |> put_flash(:info, "Character updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, character)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_character(socket, :new, character_params) do
    case Characters.create_character(socket.assigns.current_scope, character_params) do
      {:ok, character} ->
        {:noreply,
         socket
         |> put_flash(:info, "Character created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, character)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _character), do: ~p"/characters"
  defp return_path(_scope, "show", character), do: ~p"/characters/#{character}"
end
