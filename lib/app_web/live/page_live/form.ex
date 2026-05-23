defmodule AppWeb.PageLive.Form do
  use AppWeb, :live_view

  alias App.Content
  alias App.Content.Page

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage page records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="page-form" phx-change="validate" phx-submit="save">
        <div>
          <label class="block text-sm font-semibold text-white mb-1">
            Topic
          </label>

          <select
            name="page[topic_id]"
            class="block w-full rounded-md bg-white px-3 py-2 text-black"
          >
            <option value="">Choose a topic</option>

            <%= for {label, value} <- @topic_options do %>
              <option
                value={value}
                selected={to_string(value) == to_string(@form[:topic_id].value)}
              >
                {label}
              </option>
            <% end %>
          </select>
        </div>

        <.input field={@form[:content]} type="textarea" label="Content" />

        <footer>
          <button type="submit" phx-disable-with="Saving...">
            Save Page
          </button>

          <.link navigate={return_path(@return_to, @page)} class="button">
            Cancel
          </.link>
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
     |> assign(:topic_options, build_topic_options())
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    scope = socket.assigns[:current_scope]
    page = Content.get_page!(scope, id)

    socket
    |> assign(:page_title, "Edit Page")
    |> assign(:page, page)
    |> assign(:form, to_form(Content.change_page(scope, page, %{})))
  end

  defp apply_action(socket, :new, _params) do
    scope = socket.assigns[:current_scope]
    page = %Page{}

    socket
    |> assign(:page_title, "New Page")
    |> assign(:page, page)
    |> assign(:form, to_form(Content.change_page(scope, page, %{})))
  end

  @impl true
  def handle_event("validate", %{"page" => page_params}, socket) do
    scope = socket.assigns[:current_scope]

    changeset =
      Content.change_page(scope, socket.assigns.page, page_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"page" => page_params}, socket) do
    save_page(socket, socket.assigns.live_action, page_params)
  end

  @impl true
  def handle_info(message, socket) do
    AppWeb.LiveHelper.handle_info(message, socket)
  end

  defp save_page(socket, :edit, page_params) do
    scope = socket.assigns[:current_scope]

    case Content.update_page(scope, socket.assigns.page, page_params) do
      {:ok, page} ->
        {:noreply,
         socket
         |> put_flash(:info, "Page updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, page))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_page(socket, :new, page_params) do
    scope = socket.assigns[:current_scope]

    case Content.create_page(scope, page_params) do
      {:ok, page} ->
        {:noreply,
         socket
         |> put_flash(:info, "Page created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, page))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp build_topic_options do
    Content.list_topics()
    |> Enum.map(fn topic -> {topic.title, topic.id} end)
  end

  defp return_path("index", _page), do: ~p"/pages"

  defp return_path("show", page) do
    topic = Content.get_topic!(page.topic_id)
    ~p"/topics/#{topic.slug}/#{page.id}"
  end
end
