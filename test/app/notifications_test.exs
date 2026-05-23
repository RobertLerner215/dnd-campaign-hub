defmodule App.NotificationsTest do
  use App.DataCase

  alias App.Notifications

  describe "messages" do
    alias App.Notifications.Message

    import App.NotificationsFixtures

    @invalid_attrs %{message: nil, email: nil, subject: nil}

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Notifications.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Notifications.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      valid_attrs = %{message: "some message", email: "test@example.com", subject: "some subject"}

      assert {:ok, %Message{} = message} = Notifications.create_message(valid_attrs)
      assert message.message == "some message"
      assert message.email == "test@example.com"
      assert message.subject == "some subject"
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Notifications.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()

      update_attrs = %{
        message: "some updated message",
        email: "updated@example.com",
        subject: "some updated subject"
      }

      assert {:ok, %Message{} = message} = Notifications.update_message(message, update_attrs)
      assert message.message == "some updated message"
      assert message.email == "updated@example.com"
      assert message.subject == "some updated subject"
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Notifications.update_message(message, @invalid_attrs)
      assert message == Notifications.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Notifications.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Notifications.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Notifications.change_message(message)
    end
  end
end
