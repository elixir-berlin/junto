defmodule JuntosWeb.Router do
  use JuntosWeb, :router

  import JuntosWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {JuntosWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", JuntosWeb do
    pipe_through :browser

    live "/", PageLive, :index

    get "/auth/:provider", AuthProviderController, :request
    get "/auth/:provider/callback", AuthProviderController, :callback
    get "/auth/:provider/rd", AuthProviderController, :store_redirect_to

    resources "/users", UserController, only: [:new, :create]
  end

  scope "/", JuntosWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/groups/new", GroupLive.New, :new
  end

  # Other scopes may use custom stacks.
  # scope "/api", JuntosWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: JuntosWeb.Telemetry
    end
  end

  scope "/", JuntosWeb do
    pipe_through :browser

    live "/:group_slug/:slug_id", EventLive.Show, :show
    live "/*path", GroupLive.Show, :show
  end
end
