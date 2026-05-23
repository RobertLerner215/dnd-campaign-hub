defmodule AppWeb.PageLive.Show do
  use AppWeb, :live_view

  alias App.Content

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Page {@page.id}
        <:subtitle>This page belongs to topic {@topic.title}.</:subtitle>
        <:actions>
          <.link navigate={~p"/topics/#{@topic.slug}"} class="button">
            <.icon name="hero-arrow-left" />
          </.link>
          <.link navigate={~p"/pages/#{@page.id}/edit"} class="button">
            <.icon name="hero-pencil-square" /> Edit page
          </.link>
        </:actions>
      </.header>

      <.list>
        <:item title="Topic">{@topic.title}</:item>
        <:item title="Content">{@page.content}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"slug" => slug, "page_id" => page_id}, _session, socket) do
    if connected?(socket) do
      Content.subscribe_pages(socket.assigns.current_scope)
    end

    topic = Content.get_topic_by_slug!(slug)
    page = Content.get_page!(socket.assigns.current_scope, page_id)

    true = page.topic_id == topic.id

    {:ok,
     socket
     |> assign(:page_title, "Show Page")
     |> assign(:topic, topic)
     |> assign(:page, page)}
  end

  @impl true
  def handle_info(
        {:updated, %App.Content.Page{id: id} = page},
        %{assigns: %{page: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :page, page)}
  end

  def handle_info(
        {:deleted, %App.Content.Page{id: id}},
        %{assigns: %{page: %{id: id}, topic: topic}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current page was deleted.")
     |> push_navigate(to: ~p"/topics/#{topic.slug}")}
  end

  def handle_info({type, %App.Content.Page{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end

  def handle_info(message, socket) do
    AppWeb.LiveHelper.handle_info(message, socket)
  end
end
