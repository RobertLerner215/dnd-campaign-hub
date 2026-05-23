defmodule AppWeb.CharacterLive.Show do
  use AppWeb, :live_view

  alias App.Characters

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Character {@character.id}
        <:subtitle>This is a character record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/characters"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/characters/#{@character}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit character
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@character.name}</:item>
        <:item title="Race">{@character.race}</:item>
        <:item title="Class">{@character.class}</:item>
        <:item title="Level">{@character.level}</:item>
        <:item title="Hp">{@character.hp}</:item>
        <:item title="Armor class">{@character.armor_class}</:item>
        <:item title="Notes">{@character.notes}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Characters.subscribe_characters(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Character")
     |> assign(:character, Characters.get_character!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %App.Characters.Character{id: id} = character},
        %{assigns: %{character: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :character, character)}
  end

  def handle_info(
        {:deleted, %App.Characters.Character{id: id}},
        %{assigns: %{character: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current character was deleted.")
     |> push_navigate(to: ~p"/characters")}
  end

  def handle_info({type, %App.Characters.Character{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
