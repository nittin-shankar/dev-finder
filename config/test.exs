import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :dev_finder, DevFinderWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "8RFG6CVE+bf5AEdx5qWjypc31pDjgOR2n87LbimdgxKX3DYCgfYgTqGHR7Z8jmS7",
  server: false

# In test we don't send emails.
config :dev_finder, DevFinder.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
