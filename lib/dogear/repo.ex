defmodule Dogear.Repo do
  use Ecto.Repo,
    otp_app: :dogear,
    adapter: Ecto.Adapters.SQLite3
end
