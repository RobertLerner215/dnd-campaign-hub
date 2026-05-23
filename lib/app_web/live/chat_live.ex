defmodule AppWeb.ChatLive do
  use AppWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(App.PubSub, "chat")

    {:ok,
     socket
     |> stream(:messages, [])
     |> assign(:username, nil)
     |> assign(:username_form, nil)
     |> assign(:form, to_form(change_message(%{}), as: :chat))}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    case socket.assigns.live_action do
      :chat ->
        {:noreply, assign(socket, :username_form, nil)}

      :join ->
        {:noreply, assign(socket, :username_form, to_form(change_username(%{}), as: :user))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-4">Chat</h1>
      
    <!-- SCROLLABLE CHAT -->
      <ul
        id="messages"
        phx-update="stream"
        phx-hook="AutoScroll"
        class="space-y-2 pb-24 overflow-y-auto max-h-[60vh]"
      >
        <li
          :for={{id, message} <- @streams.messages}
          id={id}
          class="bg-white text-black p-2 rounded"
        >
          <%= if message.type == :message do %>
            <strong>{message.username}:</strong>
            {message.message}
          <% end %>

          <%= if message.type == :user_joined do %>
            <em>{message.username} joined the chat</em>
          <% end %>

          <%= if message.type == :user_left do %>
            <em>{message.username} left the chat</em>
          <% end %>
        </li>
      </ul>
    </div>

    <!-- INPUT BAR -->
    <div class="fixed bottom-0 left-0 right-0 bg-gray-100 dark:bg-gray-800 p-4 flex justify-center">
      <.link
        :if={!@username}
        patch={~p"/chat/join"}
        class="rounded-lg bg-blue-600 px-4 py-2 text-white hover:bg-blue-700"
      >
        Join Chat
      </.link>

      <.form
        :if={@username}
        for={@form}
        phx-change="change-message"
        phx-submit="send-message"
        phx-mounted={JS.focus(to: "#chat_message")}
        class="flex gap-2 w-full max-w-3xl items-end"
      >
        <button
          type="button"
          phx-click="leave-chat"
          class="rounded-lg bg-gray-500 px-4 py-2 text-white hover:bg-gray-600"
        >
          Leave Chat
        </button>

        <.input
          id="chat_message"
          field={@form[:message]}
          type="text"
          placeholder="Type message"
          class="flex-1"
        />

        <button
          type="submit"
          class="rounded-lg bg-blue-600 px-4 py-2 text-white hover:bg-blue-700"
        >
          Send
        </button>
      </.form>
    </div>

    <!-- MODAL -->
    <%= if @live_action == :join do %>
      <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
        <div class="bg-white p-6 rounded-xl w-full max-w-md shadow-xl">
          <h2 class="text-xl font-bold mb-4">Join Chat</h2>

          <.form
            for={@username_form}
            phx-change="change-name"
            phx-submit="join-chat"
            class="space-y-4"
          >
            <.input field={@username_form[:username]} type="text" label="Username" />

            <div class="flex justify-end gap-2">
              <.link patch={~p"/chat"} class="px-4 py-2 bg-gray-500 text-white rounded-lg">
                Cancel
              </.link>

              <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded-lg">
                Join
              </button>
            </div>
          </.form>
        </div>
      </div>
    <% end %>
    """
  end

  # =========================
  # EVENTS
  # =========================

  @impl true
  def handle_event("change-message", %{"chat" => params}, socket) do
    changeset =
      params
      |> change_message()
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset, as: :chat))}
  end

  @impl true
  def handle_event(
        "send-message",
        %{"chat" => params},
        %{assigns: %{username: username}} = socket
      )
      when not is_nil(username) do
    changeset = change_message(params)

    if changeset.valid? do
      message = %{
        id: Ecto.UUID.generate(),
        username: username,
        message: Ecto.Changeset.get_change(changeset, :message),
        type: :message
      }

      Phoenix.PubSub.broadcast(App.PubSub, "chat", message)

      {:noreply,
       socket
       |> assign(:form, to_form(change_message(%{}), as: :chat))
       # 🔥 THIS IS THE FINAL FIX
       |> push_event("focus-input", %{})}
    else
      {:noreply, assign(socket, :form, to_form(changeset, as: :chat))}
    end
  end

  @impl true
  def handle_event("change-name", %{"user" => params}, socket) do
    changeset =
      params
      |> change_username()
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :username_form, to_form(changeset, as: :user))}
  end

  @impl true
  def handle_event("join-chat", %{"user" => params}, socket) do
    changeset = change_username(params)

    if changeset.valid? do
      username = Ecto.Changeset.get_change(changeset, :username)

      message = %{
        id: Ecto.UUID.generate(),
        username: username,
        type: :user_joined
      }

      Phoenix.PubSub.broadcast(App.PubSub, "chat", message)

      {:noreply,
       socket
       |> assign(:username, username)
       |> push_patch(to: ~p"/chat")}
    else
      {:noreply, assign(socket, :username_form, to_form(changeset, as: :user))}
    end
  end

  @impl true
  def handle_event("leave-chat", _params, socket) do
    message = %{
      id: Ecto.UUID.generate(),
      username: socket.assigns.username,
      type: :user_left
    }

    Phoenix.PubSub.broadcast(App.PubSub, "chat", message)

    {:noreply, assign(socket, :username, nil)}
  end

  @impl true
  def handle_info(message, socket) do
    {:noreply, stream(socket, :messages, [message])}
  end

  # =========================
  # CHANGESETS
  # =========================

  @types_message %{message: :string}
  defp change_message(params) do
    {%{}, @types_message}
    |> Ecto.Changeset.cast(params, Map.keys(@types_message))
    |> Ecto.Changeset.validate_required([:message])
  end

  @types_username %{username: :string}
  defp change_username(params) do
    {%{}, @types_username}
    |> Ecto.Changeset.cast(params, Map.keys(@types_username))
    |> Ecto.Changeset.validate_required([:username])
    |> Ecto.Changeset.validate_length(:username, max: 16)
  end
end
