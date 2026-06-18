defmodule Flowops.Tasks do
  import Ecto.Query
  alias Flowops.Repo
  alias Flowops.Events.Task

  def list_tasks(event_id) do
    Task
    |> where([t], t.event_id == ^event_id)
    |> preload([:assigned_to_user, :created_by_user])
    |> order_by([t], asc: t.inserted_at)
    |> Repo.all()
  end

  def list_tasks_for_user(event_id, user_id) do
    Task
    |> where([t], t.event_id == ^event_id and t.assigned_to_user_id == ^user_id)
    |> preload([:assigned_to_user, :created_by_user])
    |> order_by([t], asc: t.inserted_at)
    |> Repo.all()
  end

  def create_task(attrs) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
    |> broadcast_task_update(attrs[:event_id] || attrs["event_id"])
  end

  def update_task_status(task_id, status) do
    task = Repo.get!(Task, task_id) |> Repo.preload([:assigned_to_user, :created_by_user])

    case task |> Task.changeset(%{status: status}) |> Repo.update() do
      {:ok, updated_task} ->
        broadcast_task_update({:ok, updated_task}, updated_task.event_id)
      error -> error
    end
  end

  def subscribe_tasks(event_id) do
    Phoenix.PubSub.subscribe(Flowops.PubSub, "tasks:#{event_id}")
  end

  defp broadcast_task_update({:ok, task}, event_id) when not is_nil(event_id) do
    Phoenix.PubSub.broadcast(Flowops.PubSub, "tasks:#{event_id}", {:tasks_updated, event_id})
    {:ok, task}
  end

  defp broadcast_task_update({:ok, task}, nil) do
    {:ok, task}
  end

  defp broadcast_task_update(error, _), do: error
end
