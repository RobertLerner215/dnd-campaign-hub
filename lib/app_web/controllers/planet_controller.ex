defmodule AppWeb.PlanetController do
  use AppWeb, :controller

  alias App.Planets

  def index(conn, _params) do
    planets = Planets.list_planets()
    render(conn, :index, planets: planets)
  end

  def show(conn, %{"id" => id}) do
    case Planets.get_planet(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> text("Planet not found")

      planet ->
        render(conn, :show, planet: planet)
    end
  end

  def random(conn, _params) do
    planet = Planets.get_random_planet()
    render(conn, :show, planet: planet)
  end
end
