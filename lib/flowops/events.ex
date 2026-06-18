defmodule Flowops.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias Flowops.Repo

  alias Flowops.Events.Event
  alias Flowops.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any event changes.

  The broadcasted messages match the pattern:

    * {:created, %Event{}}
    * {:updated, %Event{}}
    * {:deleted, %Event{}}

  """
  def subscribe_events(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Flowops.PubSub, "user:#{key}:events")
  end

  defp broadcast_event(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Flowops.PubSub, "user:#{key}:events", message)
  end

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events(scope)
      [%Event{}, ...]

  """
  def list_events(%Scope{} = scope) do
    Repo.all_by(Event, user_id: scope.user.id)
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(scope, 123)
      %Event{}

      iex> get_event!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(%Scope{} = scope, id) do
    Repo.get_by!(Event, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a event.

  ## Examples

      iex> create_event(scope, %{field: value})
      {:ok, %Event{}}

      iex> create_event(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(%Scope{} = scope, attrs) do
    with {:ok, event = %Event{}} <-
           %Event{}
           |> Event.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_event(scope, {:created, event})
      {:ok, event}
    end
  end

  @doc """
  Updates a event.

  ## Examples

      iex> update_event(scope, event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(scope, event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(%Scope{} = scope, %Event{} = event, attrs) do
    true = event.user_id == scope.user.id

    with {:ok, event = %Event{}} <-
           event
           |> Event.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_event(scope, {:updated, event})
      {:ok, event}
    end
  end

  @doc """
  Deletes a event.

  ## Examples

      iex> delete_event(scope, event)
      {:ok, %Event{}}

      iex> delete_event(scope, event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Scope{} = scope, %Event{} = event) do
    true = event.user_id == scope.user.id

    with {:ok, event = %Event{}} <-
           Repo.delete(event) do
      broadcast_event(scope, {:deleted, event})
      {:ok, event}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(scope, event)
      %Ecto.Changeset{data: %Event{}}

  """
  def change_event(%Scope{} = scope, %Event{} = event, attrs \\ %{}) do
    true = event.user_id == scope.user.id

    Event.changeset(event, attrs, scope)
  end
end
