defmodule Flowops.Events.CommitteeMember do
  use Ecto.Schema
  import Ecto.Changeset

  schema "event_committee_members" do
    field :role, :string
    field :attendance_status, :string, default: "absent"
    field :work_status, :string, default: "available"
    field :joined_at, :utc_datetime
    field :left_at, :utc_datetime

    belongs_to :event, Flowops.Events.Event
    belongs_to :user, Flowops.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(member, attrs) do
    member
    |> cast(attrs, [:event_id, :user_id, :role, :attendance_status, :work_status, :joined_at, :left_at])
    |> validate_required([:event_id, :user_id])
    |> validate_inclusion(:attendance_status, ["absent", "present", "left"])
    |> validate_inclusion(:work_status, ["available", "busy"])
    |> unique_constraint([:event_id, :user_id])
  end
end
