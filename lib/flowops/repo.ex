defmodule Flowops.Repo do
  use Ecto.Repo,
    otp_app: :flowops,
    adapter: Ecto.Adapters.Postgres
end
