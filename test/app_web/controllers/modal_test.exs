defmodule AppWeb.ModalTest do
  use AppWeb.ConnCase, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest

  test "renders modal with heading and content" do
    html =
      render_component(
        fn assigns ->
          ~H"""
          <AppWeb.Components.UI.Modal.modal id="test-modal" heading="Test Heading">
            Test Content
          </AppWeb.Components.UI.Modal.modal>
          """
        end,
        %{}
      )

    assert html =~ "Test Heading"
    assert html =~ "Test Content"
    assert html =~ "test-modal"
  end

  test "supports small attribute" do
    html =
      render_component(
        fn assigns ->
          ~H"""
          <AppWeb.Components.UI.Modal.modal id="small-modal" heading="Small" small>
            Content
          </AppWeb.Components.UI.Modal.modal>
          """
        end,
        %{}
      )

    assert html =~ "max-w-md"
  end

  test "supports backdrop attribute" do
    html =
      render_component(
        fn assigns ->
          ~H"""
          <AppWeb.Components.UI.Modal.modal id="backdrop-modal" heading="Backdrop" backdrop="static">
            Content
          </AppWeb.Components.UI.Modal.modal>
          """
        end,
        %{}
      )

    assert html =~ "backdrop-modal"
  end
end
