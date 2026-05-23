defmodule AppWeb.LocaleController do
  use AppWeb, :controller
  import Plug.Conn

  def put_locale(conn, _opts) do
    locale = get_session(conn, :locale) || "en"
    Gettext.put_locale(AppWeb.Gettext, locale)

    assign(conn, :locale, locale)
  end

  def update(conn, %{"locale" => locale}) when locale in ["en", "de"] do
    referer =
      get_req_header(conn, "referer")
      |> List.first()
      |> case do
        nil -> "/"
        url -> URI.parse(url).path || "/"
      end

    conn
    |> put_session(:locale, locale)
    |> redirect(to: referer)
  end

  def update(conn, _params) do
    redirect(conn, to: "/")
  end
end
