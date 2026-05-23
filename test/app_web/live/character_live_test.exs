defmodule AppWeb.CharacterLiveTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest
  import App.CharactersFixtures

  @create_attrs %{name: "some name", level: 42, race: "some race", class: "some class", hp: 42, armor_class: 42, notes: "some notes"}
  @update_attrs %{name: "some updated name", level: 43, race: "some updated race", class: "some updated class", hp: 43, armor_class: 43, notes: "some updated notes"}
  @invalid_attrs %{name: nil, level: nil, race: nil, class: nil, hp: nil, armor_class: nil, notes: nil}

  setup :register_and_log_in_user

  defp create_character(%{scope: scope}) do
    character = character_fixture(scope)

    %{character: character}
  end

  describe "Index" do
    setup [:create_character]

    test "lists all characters", %{conn: conn, character: character} do
      {:ok, _index_live, html} = live(conn, ~p"/characters")

      assert html =~ "Listing Characters"
      assert html =~ character.name
    end

    test "saves new character", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/characters")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Character")
               |> render_click()
               |> follow_redirect(conn, ~p"/characters/new")

      assert render(form_live) =~ "New Character"

      assert form_live
             |> form("#character-form", character: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#character-form", character: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/characters")

      html = render(index_live)
      assert html =~ "Character created successfully"
      assert html =~ "some name"
    end

    test "updates character in listing", %{conn: conn, character: character} do
      {:ok, index_live, _html} = live(conn, ~p"/characters")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#characters-#{character.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/characters/#{character}/edit")

      assert render(form_live) =~ "Edit Character"

      assert form_live
             |> form("#character-form", character: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#character-form", character: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/characters")

      html = render(index_live)
      assert html =~ "Character updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes character in listing", %{conn: conn, character: character} do
      {:ok, index_live, _html} = live(conn, ~p"/characters")

      assert index_live |> element("#characters-#{character.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#characters-#{character.id}")
    end
  end

  describe "Show" do
    setup [:create_character]

    test "displays character", %{conn: conn, character: character} do
      {:ok, _show_live, html} = live(conn, ~p"/characters/#{character}")

      assert html =~ "Show Character"
      assert html =~ character.name
    end

    test "updates character and returns to show", %{conn: conn, character: character} do
      {:ok, show_live, _html} = live(conn, ~p"/characters/#{character}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/characters/#{character}/edit?return_to=show")

      assert render(form_live) =~ "Edit Character"

      assert form_live
             |> form("#character-form", character: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#character-form", character: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/characters/#{character}")

      html = render(show_live)
      assert html =~ "Character updated successfully"
      assert html =~ "some updated name"
    end
  end
end
