defmodule Snakeys.Repo do
  use Ecto.Repo,
    otp_app: :snakeys,
    adapter: Ecto.Adapters.Postgres
end
