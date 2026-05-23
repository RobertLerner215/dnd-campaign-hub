defmodule AppWeb.MessageController do
  use AppWeb, :controller

  alias App.Notifications
  alias App.Notifications.Message

  def index(conn, _params) do
    messages = Notifications.list_messages()
    render(conn, :index, messages: messages)
  end

  def new(conn, _params) do
    changeset = Notifications.change_message(%Message{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"message" => message_params}) do
    case Notifications.create_message(message_params) do
      {:ok, message} ->
        conn
        |> put_flash(:info, "Message created successfully.")
        |> redirect(to: ~p"/messages/#{message}")

      {:error, %Ecto.Changeset{} = changeset} ->
        changeset = Map.put(changeset, :action, :insert)
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    message = Notifications.get_message!(id)
    render(conn, :show, message: message)
  end

  def edit(conn, %{"id" => id}) do
    message = Notifications.get_message!(id)
    changeset = Notifications.change_message(message)
    render(conn, :edit, message: message, changeset: changeset)
  end

  def update(conn, %{"id" => id, "message" => message_params}) do
    message = Notifications.get_message!(id)

    case Notifications.update_message(message, message_params) do
      {:ok, message} ->
        conn
        |> put_flash(:info, "Message updated successfully.")
        |> redirect(to: ~p"/messages/#{message}")

      {:error, %Ecto.Changeset{} = changeset} ->
        changeset = Map.put(changeset, :action, :update)
        render(conn, :edit, message: message, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    message = Notifications.get_message!(id)
    {:ok, _message} = Notifications.delete_message(message)

    conn
    |> put_flash(:info, "Message deleted successfully.")
    |> redirect(to: ~p"/messages")
  end
end
