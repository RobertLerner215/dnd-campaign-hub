defmodule AppWeb.AuthAndFormsSmokeTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "auth LiveViews render" do
    test "login page renders", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/users/log-in")

      assert html =~ "Log in"
      assert html =~ "Email"
    end

    test "registration page renders", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/users/register")

      assert html =~ "Register"
      assert html =~ "Email"
    end
  end

  describe "auth pages that need a logged in user" do
    setup :register_and_log_in_user

    test "settings page renders", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/users/settings")

      assert html =~ "Settings"
      assert html =~ "Email"
    end
  end

  describe "content form LiveViews render" do
    setup :register_and_log_in_user

    test "new topic form renders", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/topics/new")

      assert html =~ "New Topic"
      assert html =~ "Title"
      assert html =~ "Slug"
      assert html =~ "Save Topic"
    end

    test "new page form renders", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/pages/new")

      assert html =~ "New Page"
      assert html =~ "Topic"
      assert html =~ "Content"
      assert html =~ "Save Page"
    end
  end
end
