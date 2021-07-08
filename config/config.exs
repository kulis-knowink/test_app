# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :test_app,
  ecto_repos: [TestApp.Repo]

config :test_app, TestApp.Repo,
   adapter: Ecto.Adapters.Postgres,
   pool_size: 10

# Configures the endpoint
config :test_app, TestAppWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "8//QN9wKIt0GxRbziHdbMNKmiLqRB4TMO2DlKOnHu97Uplmf/dAZ/cnHcwXk/eGZ",
  render_errors: [view: TestAppWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: TestApp.PubSub,
  live_view: [signing_salt: "OL3iiaq0"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason


config :test_app, auth_zero_client_id: "b1ZyjB7Svcl3hW4LGEHJbhgGuV8hGboL"
config :test_app, auth_zero_client_secret: "3ylch3WZ7IkWi-_ouX3DelWUMcSUnbUzGplQNE5g7G9KxaZGZYCcyXm7GUzF7jiC"
config :test_app, auth_zero_audience: "https://ki-apps.us.auth0.com/api/v2/"
config :test_app, auth_zero_token_url: "https://ki-apps.us.auth0.com/oauth/token"
config :test_app, auth_zero_api_url: "https://ki-apps.us.auth0.com/api/v2"


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
