# Dogear

Dogear is a browser based personal Epub reader.

Your reading session can be resumed quickly from any browser.

## Deployment


`fly volumes create dogear --region sea --size 1`

`fly deploy --remote-only`

`fly ssh console --command /app/bin/migrate`

## Auth

Currently DogEar works with a single user. You can setup the username and password for the user by setting `AUTH_USERNAME` and `AUTH_PASSWORD` environment variables. Create `.envrc.private` with the environment variable you wish to override in `.envrc` and run `direnv allow`.

## Installation

Install Asdf on your system then run `asdf install` to install.

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
