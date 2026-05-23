defmodule AppWeb.TopicLiveTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest
  import App.ContentFixtures

  setup :register_and_log_in_user

  defp create_topic(%{scope: scope}) do
    topic = topic_fixture(scope)
    %{topic: topic}
  end

  describe "Index" do
    setup [:create_topic]

    test "lists all topics", %{conn: conn, topic: topic} do
      {:ok, _index_live, html} = live(conn, ~p"/topics")

      assert html =~ "Listing Topics"
      assert html =~ topic.title
    end
  end

  describe "Show" do
    setup [:create_topic]

    test "displays topic", %{conn: conn, topic: topic} do
      {:ok, _show_live, html} = live(conn, ~p"/topics/#{topic.slug}")

      assert html =~ "Topic"
      assert html =~ topic.title
    end
  end
end
