defmodule App.NotificationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Notifications` context.
  """

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        email: "test@example.com",
        message: "some message",
        subject: "some subject"
      })
      |> App.Notifications.create_message()

    message
  end
end
