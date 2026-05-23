defmodule AppWeb.PageLive.Index do
  use AppWeb, :live_view

  alias App.Content
  alias Phoenix.LiveView.JS

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Pages
        <:actions>
          <.link navigate={~p"/pages/new"} class="button">
            <.icon name="hero-plus" /> New Page
          </.link>
        </:actions>
      </.header>

      <.table
        id="pages"
        rows={@streams.pages}
        row_click={fn {_id, page} -> JS.navigate(page_show_path(page)) end}
      >
        <:col :let={{_id, page}} label="Content">{page.content}</:col>

        <:action :let={{_id, page}}>
          <.link navigate={page_show_path(page)}>Show</.link>
        </:action>

        <:action :let={{_id, page}}>
          <.link navigate={~p"/pages/#{page.id}/edit"}>Edit</.link>
        </:action>

        <:action :let={{id, page}}>
          <.link
            phx-click={JS.push("delete", value: %{id: page.id}) |> JS.hide(to: "##{id}")}
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
      Content.subscribe_pages()
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Pages")
     |> stream(:pages, Content.list_pages())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    page = Content.get_page!(id)
    {:ok, _} = Content.delete_page(page)

    {:noreply, stream_delete(socket, :pages, page)}
  end

  def handle_event(event, params, socket) do
    AppWeb.LiveHelper.handle_event(event, params, socket)
  end

  @impl true
  def handle_info({type, %App.Content.Page{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :pages, Content.list_pages(), reset: true)}
  end

  def handle_info(message, socket) do
    AppWeb.LiveHelper.handle_info(message, socket)
  end

  defp page_show_path(page) do
    topic = Content.get_topic!(page.topic_id)
    ~p"/topics/#{topic.slug}/#{page.id}"
  end
end
