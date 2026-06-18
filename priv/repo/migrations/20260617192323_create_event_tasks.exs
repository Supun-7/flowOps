defmodule Flowops.Repo.Migrations.CreateEventTasks do
  use Ecto.Migration

  def change do
    create table(:event_tasks) do
      add :event_id, references(:events, on_delete: :delete_all), null: false
      add :assigned_to_user_id, references(:users, on_delete: :nilify_all)
      add :created_by_user_id, references(:users, on_delete: :delete_all), null: false
      add :title, :string, null: false
      add :status, :string, default: "pending", null: false

      timestamps(type: :utc_datetime)
    end

    create index(:event_tasks, [:event_id])
    create index(:event_tasks, [:assigned_to_user_id])
  end
end
