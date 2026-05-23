defmodule AppWeb.PageLiveTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest
  import App.ContentFixtures

  setup :register_and_log_in_user

  defp create_page(%{scope: scope}) do
    topic = topic_fixture(scope)
    page = page_fixture(scope, %{topic_id: topic.id})
    %{page: page, topic: topic}
  end

  describe "Index" do
    setup [:create_page]

    test "lists all pages", %{conn: conn, page: page} do
      {:ok, _index_live, html} = live(conn, ~p"/pages")

      assert html =~ "Listing Pages"
      assert html =~ page.content
    end
  end

  describe "Show" do
    setup [:create_page]

    test "displays page", %{conn: conn, page: page, topic: topic} do
      {:ok, _show_live, html} = live(conn, ~p"/topics/#{topic.slug}/#{page.id}")

      assert html =~ "Page"
      assert html =~ page.content
    end
  end
end
