defmodule ClarxWeb.Router do
  use ClarxWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug ClarxWeb.Plugs.AuthenticationPlug
  end

  scope "/api", ClarxWeb do
    pipe_through :api

    post "/signup", AuthController, :signup
    post "/signin", AuthController, :signin
    delete "/signout", AuthController, :signout

    post "/renew", AuthController, :renew
    post "/reset", AuthController, :reset

    post "/code/send", AuthController, :send_code
    get "/code/revoke", AuthController, :revoke_code
  end

  scope "/api", ClarxWeb do
    pipe_through [:api, :auth]

    get "/me", UserController, :me

    resources "/users", UserController, except: [:new, :edit]
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:clarx, :dev_routes) do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
