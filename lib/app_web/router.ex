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

  # -----------------------------
  # JSON API ROUTES
  # -----------------------------
  scope "/api", AppWeb do
    pipe_through :api

    get "/dnd/characters", DndApiController, :characters
    get "/dnd/inventory", DndApiController, :inventory
    get "/dnd/quests", DndApiController, :quests
    get "/dnd/summary", DndApiController, :campaign_summary
  end

  # -----------------------------
  # AUTH REQUIRED ROUTES
  # -----------------------------
  scope "/", AppWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/messages", MessageController, :index
    get "/messages/:id/edit", MessageController, :edit
    put "/messages/:id", MessageController, :update
    patch "/messages/:id", MessageController, :update
    delete "/messages/:id", MessageController, :delete

    live_session :require_authenticated_user,
      on_mount: [
        {AppWeb.UserAuth, :put_locale},
        {AppWeb.UserAuth, :require_authenticated}
      ] do
      live "/users/settings", UserLive.Settings, :edit

      # D&D Final Project - login required
      live "/dnd", DndLive.Dashboard, :index
      live "/dnd/dice", DndLive.Dice, :index
      live "/dnd/quests", DndLive.Quests, :index

      live "/dnd/characters", CharacterLive.Index, :index
      live "/dnd/characters/new", CharacterLive.Form, :new
      live "/dnd/characters/:id/edit", CharacterLive.Form, :edit
      live "/dnd/characters/:id", CharacterLive.Show, :show

      live "/dnd/inventory", DndLive.InventoryItemLive.Index, :index
      live "/dnd/inventory/new", DndLive.InventoryItemLive.Form, :new
      live "/dnd/inventory/:id/edit", DndLive.InventoryItemLive.Form, :edit
      live "/dnd/inventory/:id", DndLive.InventoryItemLive.Show, :show

      live "/dnd/notes", DndLive.NoteLive.Index, :index
      live "/dnd/notes/new", DndLive.NoteLive.Form, :new
      live "/dnd/notes/:id/edit", DndLive.NoteLive.Form, :edit
      live "/dnd/notes/:id", DndLive.NoteLive.Show, :show

      live "/dnd/initiative", DndLive.Initiative, :index

      # Temporary character routes for generated links
      live "/characters", CharacterLive.Index, :index
      live "/characters/new", CharacterLive.Form, :new
      live "/characters/:id/edit", CharacterLive.Form, :edit
      live "/characters/:id", CharacterLive.Show, :show
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  # -----------------------------
  # PUBLIC ROUTES
  # -----------------------------
  scope "/", AppWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/courses", PageController, :courses
    get "/courses/:slug", PageController, :courses

    get "/planets", PlanetController, :index
    get "/planets/random", PlanetController, :random
    get "/planets/:id", PlanetController, :show

    get "/messages/new", MessageController, :new
    post "/messages", MessageController, :create
    get "/messages/:id", MessageController, :show

    live_session :public,
      on_mount: [{AppWeb.UserAuth, :mount_current_scope}] do
      live "/live/planets", PlanetsLive
      live "/facemash", FacemashLive

      live "/chat", ChatLive, :chat
      live "/chat/join", ChatLive, :join

      live "/accessibility", AccessibilityLive, :index
      live "/animations", AnimationsLive
      live "/gallery", GalleryLive

      live "/rock-paper-scissors", RockPaperScissorsLive, :index
      live "/rock-paper-scissors/:id", RockPaperScissorsLive, :show

      # MINESWEEPER
      live "/minesweeper", MinesweeperLive
      live "/minesweeper/:id", MinesweeperLive

      # Pages
      live "/pages", PageLive.Index, :index
      live "/pages/new", PageLive.Form, :new
      live "/pages/:id/edit", PageLive.Form, :edit
      live "/pages/:id", PageLive.Show, :show

      # Topics
      live "/topics", TopicLive.Index, :index
      live "/topics/new", TopicLive.Form, :new
      live "/topics/:id/edit", TopicLive.Form, :edit
      live "/topics/:slug", TopicLive.Show, :show
      live "/topics/:slug/:page_id", PageLive.Show, :show

      # Items
      live "/items", ItemLive.Index, :index
      live "/items/new", ItemLive.Form, :new
      live "/items/:id/edit", ItemLive.Form, :edit
      live "/items/:id", ItemLive.Show, :show

      live "/charts", ChartsLive
    end

    put "/locale/:locale", LocaleController, :update
  end

  # -----------------------------
  # DEV ROUTES
  # -----------------------------
  if Application.compile_env(:app, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AppWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  # -----------------------------
  # AUTH ROUTES
  # -----------------------------
  scope "/", AppWeb do
    pipe_through :browser

    live_session :current_user,
      on_mount: [
        {AppWeb.UserAuth, :put_locale},
        {AppWeb.UserAuth, :mount_current_scope}
      ] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
