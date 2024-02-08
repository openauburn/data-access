defmodule DataAccessApi.Repo do
  use Ecto.Repo,
    otp_app: :data_access_api,
    adapter: Ecto.Adapters.Postgres
end
