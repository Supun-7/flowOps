defmodule Flowops.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :title, :string
    field :description, :string
    field :location, :string
    field :start_time, :naive_datetime
    field :end_time, :naive_datetime
    field :status, :string, default: "upcoming"
    field :cover_image, :string
    field :map_link, :string
    field :capacity, :integer
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event, attrs, user_scope) do
    event
    |> cast(attrs, [
      :title,
      :description,
      :location,
      :start_time,
      :end_time,
      :status,
      :cover_image,
      :map_link,
      :capacity
    ])
    |> validate_required([:title, :location, :start_time, :end_time])
    |> validate_inclusion(:status, ["upcoming", "live", "ended"])
    |> put_change(:user_id, user_scope.user.id)
  end
end
