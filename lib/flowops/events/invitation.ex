defmodule Flowops.Events.Invitation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "event_invitations" do
    field :status, :string, default: "pending"
    field :role, :string

    belongs_to :event, Flowops.Events.Event
    belongs_to :invited_user, Flowops.Accounts.User, foreign_key: :invited_user_id
    belongs_to :invited_by_user, Flowops.Accounts.User, foreign_key: :invited_by_user_id

    timestamps(type: :utc_datetime)
  end

  def changeset(invitation, attrs) do
    invitation
    |> cast(attrs, [:event_id, :invited_user_id, :invited_by_user_id, :status, :role])
    |> validate_required([:event_id, :invited_user_id, :invited_by_user_id])
    |> validate_inclusion(:status, ["pending", "accepted", "declined"])
    |> unique_constraint([:event_id, :invited_user_id])
  end
end
