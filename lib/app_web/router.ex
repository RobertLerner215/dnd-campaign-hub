defmodule AppWeb.Router do
  use AppWeb, :router

  import AppWeb.UserAuth
  import AppWeb.LocaleController, only: [put_locale: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :put_locale
    plug :fetch_live_flash
    plug :put_root_layout, html: {AppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # ---------------------------------
  # PUBLIC ROUTES
  # ---------------------------------
  scope "/", AppWeb do
    pipe_through :browser

    get "/", PageController, :home

    live_session :public,
      on_mount: [{AppWeb.UserAuth, :mount_current_scope}] do

      # Campaigns
      live "/campaigns", CampaignLive.Index, :index
      live "/campaigns/new", CampaignLive.Form, :new
      live "/campaigns/:id", CampaignLive.Show, :show
      live "/campaigns/:id/edit", CampaignLive.Form, :edit

      # Characters
      live "/characters", CharacterLive.Index, :index
      live "/characters/new", CharacterLive.Form, :new
      live "/characters/:id", CharacterLive.Show, :show
      live "/characters/:id/edit", CharacterLive.Form, :edit

      # Inventory
      live "/inventory", InventoryLive.Index, :index
      live "/inventory/new", InventoryLive.Form, :new
      live "/inventory/:id", InventoryLive.Show, :show
      live "/inventory/:id/edit", InventoryLive.Form, :edit

      # Monsters
      live "/monsters", MonsterLive.Index, :index
      live "/monsters/:id", MonsterLive.Show, :show

      # Utilities
      live "/dice", DiceLive.Index, :index
      live "/chat", ChatLive, :chat
    end

    put "/locale/:locale", LocaleController, :update
  end

  # ---------------------------------
  # MINIMAL AUTH ROUTES
  # ---------------------------------
  scope "/", AppWeb do
    pipe_through :browser

    live_session :current_user,
      on_mount: [{AppWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end

  # ---------------------------------
  # DEV ROUTES
  # ---------------------------------
  if Application.compile_env(:app, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AppWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
