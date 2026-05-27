defmodule Flowops.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Flowops.Events` context.
  """

  @doc """
  Generate a event.
  """
  def event_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        description: "some description",
        end_time: ~N[2026-05-25 16:20:00],
        location: "some location",
        start_time: ~N[2026-05-25 16:20:00],
        title: "some title"
      })

    {:ok, event} = Flowops.Events.create_event(scope, attrs)
    event
  end

  @doc """
  Generate a event.
  """
  def event_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        description: "some description",
        end_time: ~N[2026-05-25 18:05:00],
        location: "some location",
        start_time: ~N[2026-05-25 18:05:00],
        title: "some title"
      })

    {:ok, event} = Flowops.Events.create_event(scope, attrs)
    event
  end
end
