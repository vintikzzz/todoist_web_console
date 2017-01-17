# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :todoist_web_console, TodoistWebConsole.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "II7bdb07EBWu8/TgPXI8djvLTP41gDxszJVINuraQIjp+P6LMsuqb7o08Hziohy6",
  render_errors: [view: TodoistWebConsole.ErrorView, accepts: ~w(html json)],
  pubsub: [name: TodoistWebConsole.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :todoist_web_console, Todoist.OAuth,
  client_id: "d25d4577a9a643229a12a5d69afb1090",
  client_secret: "5e78e5904057482c844400ef9fc76618",
  redirect_uri: "http://lvh.me:4000/auth/callback"

config :todoist_web_console, Todoist.API,
  url: "https://todoist.com/API/v7/sync"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
