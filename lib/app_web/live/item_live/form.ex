defmodule AppWeb.ItemLive.Form do
  use AppWeb, :live_view

  alias App.Items
  alias App.Items.Item

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage item records.</:subtitle>
      </.header>

      <.form for={@form} id="item-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />

        <%= for i <- 1..8 do %>
          <label>
            <.input field={@form[:"attr#{i}"]} type="checkbox" /> Attr {i}
          </label>
        <% end %>

        <footer>
          <button phx-disable-with="Saving..." variant="primary">
            Save Item
          </button>

          <.link navigate={~p"/items"}>
            <button>
              Cancel
            </button>
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
     |> assign(:return_to, "index")
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    item = %Item{}

    socket
    |> assign(:page_title, "New Item")
    |> assign(:item, item)
    |> assign(:form, to_form(Item.changeset(item, %{}, socket.assigns[:current_scope])))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    scope = socket.assigns[:current_scope]
    item = Items.get_item!(scope, id)

    socket
    |> assign(:page_title, "Edit Item")
    |> assign(:item, item)
    |> assign(:form, to_form(Items.change_item(scope, item)))
  end

  @impl true
  def handle_event("validate", %{"item" => item_params}, socket) do
    changeset =
      Item.changeset(socket.assigns.item, item_params, socket.assigns[:current_scope])

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"item" => item_params}, socket) do
    scope = socket.assigns[:current_scope]

    case socket.assigns.live_action do
      :new ->
        case Items.create_item(scope, item_params) do
          {:ok, _item} ->
            {:noreply,
             socket
             |> put_flash(:info, "Item created successfully")
             |> push_navigate(to: ~p"/items")}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, form: to_form(changeset))}

          {:error, :unauthorized} ->
            {:noreply,
             socket
             |> put_flash(:error, "Login required")
             |> push_navigate(to: ~p"/users/log-in")}
        end

      :edit ->
        case Items.update_item(scope, socket.assigns.item, item_params) do
          {:ok, _item} ->
            {:noreply,
             socket
             |> put_flash(:info, "Item updated successfully")
             |> push_navigate(to: ~p"/items")}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, form: to_form(changeset))}

          {:error, :unauthorized} ->
            {:noreply,
             socket
             |> put_flash(:error, "Login required")
             |> push_navigate(to: ~p"/users/log-in")}
        end
    end
  end
end
