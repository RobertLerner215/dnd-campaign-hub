defmodule AppWeb.NavbarTest do
  use AppWeb.ConnCase, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest

  test "renders navbar component" do
    html =
      render_component(
        fn assigns ->
          ~H"""
          <AppWeb.Components.UI.Navbar.navbar />
          """
        end,
        %{}
      )

    assert html =~ "Robert Lerner"
    assert html =~ "Home"
    assert html =~ "Courses"
    assert html =~ "Planets"
  end
end
