defmodule AppWeb.UI do
  @moduledoc """
  UI component entrypoint.
  """

  use Phoenix.Component

  def badge(assigns), do: AppWeb.Components.UI.Badge.badge(assigns)
  def button(assigns), do: AppWeb.Components.UI.Button.button(assigns)

  # Corrected paths
  def card(assigns), do: AppWeb.UI.Card.card(assigns)
  def navbar(assigns), do: AppWeb.Components.UI.Navbar.navbar(assigns)
  def modal(assigns), do: AppWeb.Components.UI.Modal.modal(assigns)
end
