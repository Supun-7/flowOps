defmodule Flowops.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :title, :string
      add :description, :text
      add :location, :string
      add :start_time, :naive_datetime
      add :end_time, :naive_datetime
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:events, [:user_id])
  end
end
