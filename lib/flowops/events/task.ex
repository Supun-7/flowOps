defmodule Flowops.Events.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "event_tasks" do
    field :title, :string
    field :status, :string, default: "pending"

    belongs_to :event, Flowops.Events.Event
    belongs_to :assigned_to_user, Flowops.Accounts.User, foreign_key: :assigned_to_user_id
    belongs_to :created_by_user, Flowops.Accounts.User, foreign_key: :created_by_user_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :status, :event_id, :assigned_to_user_id, :created_by_user_id])
    |> validate_required([:title, :status, :event_id, :created_by_user_id])
    |> validate_inclusion(:status, ["pending", "in_progress", "done"])
  end
end
