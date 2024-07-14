# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :clarx,
  namespace: ClarxCore,
  ecto_repos: [ClarxCore.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configures the endpoint
config :clarx, ClarxWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [json: ClarxWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ClarxCore.PubSub,
  live_view: [signing_salt: "X7dmmVdN"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :clarx, ClarxCore.Mailer, adapter: Swoosh.Adapters.Local

# Configures the database timezone
config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Configures JWT secret key
config :clarx, ClarxCore.JsonWebToken,
  jwt_secret_key:
    System.get_env(
      "JWT_SECRET_KEY",
      "R0ST673WsXDICXInu/2jWaBB+QYe9YevWBzmtSJd6sYo5VQd3P/3S2d7JAoUvyQO"
    )

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
