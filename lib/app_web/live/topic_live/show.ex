defmodule AppWeb.TopicLive.Show do
  use AppWeb, :live_view

  alias App.Content

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Topic {@topic.slug}
        <:subtitle>This is a topic record from your database.</:subtitle>
        <:actions>
          <.link navigate={~p"/topics"} class="button">
            <.icon name="hero-arrow-left" />
          </.link>
          <.link navigate={~p"/topics/#{@topic.slug}/edit"} class="button">
            <.icon name="hero-pencil-square" /> Edit topic
          </.link>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@topic.title}</:item>
        <:item title="Slug">{@topic.slug}</:item>
      </.list>

      <div class="mt-8">
        <h2 class="text-xl font-bold mb-4">Pages in this topic</h2>

        <%= if @pages == [] do %>
          <p>No pages yet for this topic.</p>
        <% else %>
          <ul class="space-y-2">
            <%= for page <- @pages do %>
              <li>
                <.link
                  navigate={~p"/topics/#{@topic.slug}/#{page.id}"}
                  class="underline text-blue-300"
                >
                  Page {page.id}: {page.content}
                </.link>
              </li>
            <% end %>
          </ul>
        <% end %>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    if connected?(socket) do
      Content.subscribe_topics(socket.assigns.current_scope)
      Content.subscribe_pages(socket.assigns.current_scope)
    end

    topic = Content.get_topic_by_slug!(slug)
    pages = topic_pages(socket.assigns.current_scope, topic.id)

    {:ok,
     socket
     |> assign(:page_title, "Show Topic")
     |> assign(:topic, topic)
     |> assign(:pages, pages)}
  end

  @impl true
  def handle_info(
        {:updated, %App.Content.Topic{id: id} = topic},
        %{assigns: %{topic: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :topic, topic)}
  end

  def handle_info(
        {:deleted, %App.Content.Topic{id: id}},
        %{assigns: %{topic: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current topic was deleted.")
     |> push_navigate(to: ~p"/topics")}
  end

  def handle_info({type, %App.Content.Page{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     assign(socket, :pages, topic_pages(socket.assigns.current_scope, socket.assigns.topic.id))}
  end

  def handle_info({type, %App.Content.Topic{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end

  def handle_info(message, socket) do
    AppWeb.LiveHelper.handle_info(message, socket)
  end

  defp topic_pages(current_scope, topic_id) do
    Content.list_pages(current_scope)
    |> Enum.filter(fn page -> page.topic_id == topic_id end)
  end
end
