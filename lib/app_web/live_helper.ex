defmodule AppWeb.LiveHelper do
  use AppWeb, :live_view

  def handle_event("logout", _params, socket) do
    Phoenix.PubSub.broadcast(
      App.PubSub,
      "user:#{socket.assigns.current_scope.user.id}",
      :logout
    )

    {:noreply, socket}
  end

  def handle_info(:logout, socket) do
    {:noreply, push_event(socket, "logout", %{})}
  end
end
