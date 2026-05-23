defmodule AppWeb.CharacterLive.Index do
  use AppWeb, :live_view

  alias App.Characters
  alias Phoenix.LiveView.JS

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Characters
        <:actions>
          <.button variant="primary" navigate={~p"/characters/new"}>
            <.icon name="hero-plus" /> New Character
          </.button>
        </:actions>
      </.header>

      <.table
        id="characters"
        rows={@streams.characters}
        row_click={fn {_id, character} -> JS.navigate(~p"/characters/#{character}") end}
      >
        <:col :let={{_id, character}} label="Name">{character.name}</:col>
        <:col :let={{_id, character}} label="Race">{character.race}</:col>
        <:col :let={{_id, character}} label="Class">{character.class}</:col>
        <:col :let={{_id, character}} label="Level">{character.level}</:col>
        <:col :let={{_id, character}} label="Hp">{character.hp}</:col>
        <:col :let={{_id, character}} label="Armor class">{character.armor_class}</:col>
        <:col :let={{_id, character}} label="Notes">{character.notes}</:col>

        <:action :let={{_id, character}}>
          <div class="sr-only">
            <.link navigate={~p"/characters/#{character}"}>Show</.link>
          </div>
          <.link navigate={~p"/characters/#{character}/edit"}>Edit</.link>
        </:action>

        <:action :let={{id, character}}>
          <.link
            phx-click={
              JS.push("delete", value: %{id: character.id})
              |> JS.hide(to: "##{id}")
            }
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Characters.subscribe_characters(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Characters")
     |> stream(:characters, list_characters(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    character = Characters.get_character!(socket.assigns.current_scope, id)
    {:ok, _} = Characters.delete_character(socket.assigns.current_scope, character)

    {:noreply, stream_delete(socket, :characters, character)}
  end

  @impl true
  def handle_info({type, %App.Characters.Character{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(
       socket,
       :characters,
       list_characters(socket.assigns.current_scope),
       reset: true
     )}
  end

  defp list_characters(current_scope) do
    Characters.list_characters(current_scope)
  end
end
