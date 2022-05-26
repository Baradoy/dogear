defmodule DogearWeb.Router do
  use DogearWeb, :router

  pipeline :browser do
    plug :auth
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {DogearWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DogearWeb do
    pipe_through :browser

    live "/", BookmarkLive.Index, :index

    live "/books", BookLive.Index, :index
    live "/books/new", BookLive.Index, :new
    live "/books/:id/edit", BookLive.Index, :edit

    live "/books/:id", BookLive.Show, :show
    live "/books/:id/show/edit", BookLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", DogearWeb do
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

      live_dashboard "/dashboard", metrics: DogearWeb.Telemetry
    end
  end

  defp auth(conn, _opts) do
    if !(Application.get_env(:dogear, :environment) in [:dev, :test]) do
      username = System.fetch_env!("AUTH_USERNAME")
      password = System.fetch_env!("AUTH_PASSWORD")
      Plug.BasicAuth.basic_auth(conn, username: username, password: password)
    end

    conn
  end
end
