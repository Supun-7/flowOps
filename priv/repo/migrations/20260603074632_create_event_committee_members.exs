defmodule Flowops.Repo.Migrations.CreateEventCommitteeMembers do
  use Ecto.Migration

  def change do
    create table(:event_committee_members) do
      add :event_id, references(:events, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :role, :string
      add :attendance_status, :string, default: "absent", null: false
      add :work_status, :string, default: "available", null: false
      add :joined_at, :utc_datetime
      add :left_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:event_committee_members, [:event_id])
    create index(:event_committee_members, [:user_id])
    create unique_index(:event_committee_members, [:event_id, :user_id])
  end
end
