defmodule Flowops.EventsTest do
  use Flowops.DataCase

  alias Flowops.Events

  describe "events" do
    alias Flowops.Events.Event

    import Flowops.AccountsFixtures, only: [user_scope_fixture: 0]
    import Flowops.EventsFixtures

    @invalid_attrs %{description: nil, title: nil, location: nil, start_time: nil, end_time: nil}

    test "list_events/1 returns all scoped events" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      event = event_fixture(scope)
      other_event = event_fixture(other_scope)
      assert Events.list_events(scope) == [event]
      assert Events.list_events(other_scope) == [other_event]
    end

    test "get_event!/2 returns the event with given id" do
      scope = user_scope_fixture()
      event = event_fixture(scope)
      other_scope = user_scope_fixture()
      assert Events.get_event!(scope, event.id) == event
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(other_scope, event.id) end
    end

    test "create_event/2 with valid data creates a event" do
      valid_attrs = %{description: "some description", title: "some title", location: "some location", start_time: ~N[2026-05-25 16:20:00], end_time: ~N[2026-05-25 16:20:00]}
      scope = user_scope_fixture()

      assert {:ok, %Event{} = event} = Events.create_event(scope, valid_attrs)
      assert event.description == "some description"
      assert event.title == "some title"
      assert event.location == "some location"
      assert event.start_time == ~N[2026-05-25 16:20:00]
      assert event.end_time == ~N[2026-05-25 16:20:00]
      assert event.user_id == scope.user.id
    end

    test "create_event/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.create_event(scope, @invalid_attrs)
    end

    test "update_event/3 with valid data updates the event" do
      scope = user_scope_fixture()
      event = event_fixture(scope)
      update_attrs = %{description: "some updated description", title: "some updated title", location: "some updated location", start_time: ~N[2026-05-26 16:20:00], end_time: ~N[2026-05-26 16:20:00]}

      assert {:ok, %Event{} = event} = Events.update_event(scope, event, update_attrs)
      assert event.description == "some updated description"
      assert event.title == "some updated title"
      assert event.location == "some updated location"
      assert event.start_time == ~N[2026-05-26 16:20:00]
      assert event.end_time == ~N[2026-05-26 16:20:00]
    end

    test "update_event/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      event = event_fixture(scope)

      assert_raise MatchError, fn ->
        Events.update_event(other_scope, event, %{})
      end
    end

    test "update_event/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      event = event_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Events.update_event(scope, event, @invalid_attrs)
      assert event == Events.get_event!(scope, event.id)
    end

    test "delete_event/2 deletes the event" do
      scope = user_scope_fixture()
      event = event_fixture(scope)
      assert {:ok, %Event{}} = Events.delete_event(scope, event)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(scope, event.id) end
    end

    test "delete_event/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      event = event_fixture(scope)
      assert_raise MatchError, fn -> Events.delete_event(other_scope, event) end
    end

    test "change_event/2 returns a event changeset" do
      scope = user_scope_fixture()
      event = event_fixture(scope)
      assert %Ecto.Changeset{} = Events.change_event(scope, event)
    end
  end
end
