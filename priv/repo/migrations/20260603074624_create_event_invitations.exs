defmodule Flowops.Repo.Migrations.CreateEventInvitations do
  use Ecto.Migration

  def change do
    create table(:event_invitations) do
      add :event_id, references(:events, on_delete: :delete_all), null: false
      add :invited_user_id, references(:users, on_delete: :delete_all), null: false
      add :invited_by_user_id, references(:users, on_delete: :delete_all), null: false
      add :status, :string, default: "pending", null: false
      add :role, :string

      timestamps(type: :utc_datetime)
    end

    create index(:event_invitations, [:event_id])
    create index(:event_invitations, [:invited_user_id])
    create unique_index(:event_invitations, [:event_id, :invited_user_id])
  end
end
