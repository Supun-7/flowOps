defmodule FlowopsWeb.EventLive.Index do
  use FlowopsWeb, :live_view
  alias Flowops.Events
  alias Flowops.Invitations
  alias FlowopsWeb.DashboardNav

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="fixed inset-0 top-0 bg-gray-50 overflow-y-auto z-40">

        <DashboardNav.dashboard_nav
          current_scope={@current_scope}
          has_events={@has_events}
          has_assignments={@has_assignments}
        />

        <div class="p-6 max-w-6xl mx-auto">

          <div class="mb-8 mt-4">
            <h1 class="text-3xl font-extrabold text-gray-800">Welcome back! 👋</h1>
            <p class="text-gray-500 mt-1">{@current_scope.user.email}</p>
          </div>

          <!-- Stats Cards -->
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-8">
            <div class="bg-white rounded-2xl shadow p-6 flex items-center gap-4">
              <div class="bg-purple-100 rounded-xl p-3">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-purple-700" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
              </div>
              <div>
                <p class="text-sm text-gray-500">Total Events</p>
                <p class="text-2xl font-bold text-gray-800">{@total_events}</p>
              </div>
            </div>

            <div class="bg-white rounded-2xl shadow p-6 flex items-center gap-4">
              <div class="bg-indigo-100 rounded-xl p-3">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-indigo-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <div>
                <p class="text-sm text-gray-500">Upcoming</p>
                <p class="text-2xl font-bold text-gray-800">{@upcoming_events}</p>
              </div>
            </div>

            <div class="bg-white rounded-2xl shadow p-6 flex items-center gap-4">
              <div class="bg-slate-100 rounded-xl p-3">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-slate-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                </svg>
              </div>
              <div>
                <p class="text-sm text-gray-500">Past Events</p>
                <p class="text-2xl font-bold text-gray-800">{@past_events}</p>
              </div>
            </div>
          </div>

          <!-- Events List Header -->
          <div class="flex items-center justify-between mb-4">
            <h2 class="text-xl font-bold text-gray-800">My Events</h2>
            <.link navigate={~p"/events/new"} class="px-4 py-2 rounded-xl bg-gradient-to-r from-purple-700 to-indigo-600 text-white text-sm font-bold hover:opacity-90 transition">
              + New Event
            </.link>
          </div>

          <!-- Events List -->
          <div class="space-y-3">
            <div
              :for={{id, event} <- @streams.events}
              id={id}
              class="bg-white rounded-2xl shadow p-5 flex items-center justify-between hover:shadow-md transition"
            >
              <div>
                <h3 class="text-lg font-bold text-gray-800">{event.title}</h3>
                <p class="text-gray-500 text-sm">{event.location}</p>
                <p class="text-gray-400 text-xs mt-1">{event.start_time}</p>
              </div>
              <div class="flex gap-2">
                <.link navigate={~p"/events/#{event}"} class="px-3 py-1 rounded-xl border border-purple-300 text-purple-700 text-sm font-medium hover:bg-purple-50 transition">
                  View
                </.link>
                <.link navigate={~p"/events/#{event}/edit"} class="px-3 py-1 rounded-xl bg-purple-100 text-purple-700 text-sm font-medium hover:bg-purple-200 transition">
                  Edit
                </.link>
                <.link
                  phx-click={JS.push("delete", value: %{id: event.id}) |> hide("##{id}")}
                  data-confirm="Are you sure?"
                  class="px-3 py-1 rounded-xl bg-red-100 text-red-600 text-sm font-medium hover:bg-red-200 transition"
                >
                  Delete
                </.link>
              </div>
            </div>

            <div :if={!@has_events} class="text-center py-16 text-gray-400">
              <p class="text-lg font-medium">No events yet</p>
              <p class="text-sm mt-1">Create your first event to get started</p>
            </div>
          </div>

        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Events.subscribe_events(socket.assigns.current_scope)
    end

    user_id = socket.assigns.current_scope.user.id
    events = list_events(socket.assigns.current_scope)
    now = NaiveDateTime.utc_now()

    {:ok,
     socket
     |> assign(:page_title, "Dashboard")
     |> assign(:total_events, length(events))
     |> assign(:has_events, length(events) > 0)
     |> assign(:has_assignments, length(Invitations.list_committee_assignments(user_id)) > 0)
     |> assign(:upcoming_events, Enum.count(events, &(NaiveDateTime.compare(&1.start_time, now) == :gt)))
     |> assign(:past_events, Enum.count(events, &(NaiveDateTime.compare(&1.start_time, now) == :lt)))
     |> stream(:events, events)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event = Events.get_event!(socket.assigns.current_scope, id)
    {:ok, _} = Events.delete_event(socket.assigns.current_scope, event)
    {:noreply, stream_delete(socket, :events, event)}
  end

  @impl true
  def handle_info({type, %Flowops.Events.Event{}}, socket)
      when type in [:created, :updated, :deleted] do
    events = list_events(socket.assigns.current_scope)
    now = NaiveDateTime.utc_now()
    user_id = socket.assigns.current_scope.user.id

    {:noreply,
     socket
     |> assign(:total_events, length(events))
     |> assign(:has_events, length(events) > 0)
     |> assign(:has_assignments, length(Invitations.list_committee_assignments(user_id)) > 0)
     |> assign(:upcoming_events, Enum.count(events, &(NaiveDateTime.compare(&1.start_time, now) == :gt)))
     |> assign(:past_events, Enum.count(events, &(NaiveDateTime.compare(&1.start_time, now) == :lt)))
     |> stream(:events, events, reset: true)}
  end

  defp list_events(current_scope) do
    Events.list_events(current_scope)
  end
end
