defmodule AppWeb.TopicLive.Index do
  use AppWeb, :live_view

  alias App.Content

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Topics
        <:actions>
          <.link navigate={~p"/topics/new"} class="button">
            <.icon name="hero-plus" /> New Topic
          </.link>
        </:actions>
      </.header>

      <.table
        id="topics"
        rows={@streams.topics}
        row_click={fn {_id, topic} -> JS.navigate(~p"/topics/#{topic.slug}") end}
      >
        <:col :let={{_id, topic}} label="Title">{topic.title}</:col>
        <:col :let={{_id, topic}} label="Slug">{topic.slug}</:col>

        <:action :let={{_id, topic}}>
          <.link navigate={~p"/topics/#{topic.slug}"}>Show</.link>
        </:action>

        <:action :let={{_id, topic}}>
          <.link navigate={~p"/topics/#{topic}/edit"}>Edit</.link>
        </:action>

        <:action :let={{id, topic}}>
          <.link
            phx-click={JS.push("delete", value: %{id: topic.id}) |> JS.hide(to: "##{id}")}
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
      Content.subscribe_topics(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Topics")
     |> stream(:topics, Content.list_topics())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    topic = Content.get_topic!(id)
    {:ok, _} = Content.delete_topic(topic)

    {:noreply, stream(socket, :topics, Content.list_topics(), reset: true)}
  end

  def handle_event(event, params, socket) do
    AppWeb.LiveHelper.handle_event(event, params, socket)
  end

  @impl true
  def handle_info({type, %App.Content.Topic{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :topics, Content.list_topics(), reset: true)}
  end

  def handle_info(message, socket) do
    AppWeb.LiveHelper.handle_info(message, socket)
  end
end
