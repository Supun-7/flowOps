defmodule FlowopsWeb.EventLive.Index do
  use FlowopsWeb, :live_view
  alias Flowops.Events

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="fixed inset-0 top-0 bg-gray-50 overflow-y-auto z-40">

        <!-- Nav Bar -->
        <nav class="w-full flex items-center justify-between px-6 py-4 bg-gradient-to-r from-violet-600 via-fuchsia-500 to-orange-400 shadow-md">
          <a href="/" class="flex items-center gap-2 text-white font-extrabold text-xl">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
            </svg>
            FlowOps
          </a>
          <div class="flex items-center gap-3">
            <span class="text-white/80 text-sm hidden sm:block">
              {@current_scope.user.email}
            </span>
            <a href={~p"/users/settings"} class="btn btn-sm bg-white/20 text-white border-none hover:bg-white/30">
              Settings
            </a>
            <.link href={~p"/users/log-out"} method="delete" class="btn btn-sm bg-white text-violet-700 font-bold border-none hover:bg-white/90">
              Log out
            </.link>
          </div>
        </nav>

        <!-- Main Content -->
        <div class="p-6 max-w-6xl mx-auto">

          <!-- Welcome Header -->
          <div class="mb-8 mt-4">
            <h1 class="text-3xl font-extrabold text-gray-800">
              Welcome back! 👋
            </h1>
            <p class="text-gray-500 mt-1">
              {@current_scope.user.email}
            </p>
          </div>

          <!-- Stats Cards -->
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-8">
            <div class="bg-white rounded-2xl shadow p-6 flex items-center gap-4">
              <div class="bg-violet-100 rounded-xl p-3">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-violet-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
              </div>
              <div>
                <p class="text-sm text-gray-500">Total Events</p>
                <p class="text-2xl font-bold text-gray-800">{@total_events}</p>
              </div>
            </div>

            <div class="bg-white rounded-2xl shadow p-6 flex items-center gap-4">
              <div class="bg-fuchsia-100 rounded-xl p-3">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-fuchsia-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <div>
                <p class="text-sm text-gray-500">Upcoming</p>
                <p class="text-2xl font-bold text-gray-800">{@upcoming_events}</p>
              </div>
            </div>

            <div class="bg-white rounded-2xl shadow p-6 flex items-center gap-4">
              <div class="bg-orange-100 rounded-xl p-3">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-orange-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
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
            <.link navigate={~p"/events/new"} class="btn bg-gradient-to-r from-violet-600 to-fuchsia-500 text-white border-none hover:opacity-90">
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
                <.link navigate={~p"/events/#{event}"} class="btn btn-sm btn-outline border-violet-400 text-violet-600 hover:bg-violet-50">
                  View
                </.link>
                <.link navigate={~p"/events/#{event}/edit"} class="btn btn-sm bg-violet-100 text-violet-700 border-none hover:bg-violet-200">
                  Edit
                </.link>
                <.link
                  phx-click={JS.push("delete", value: %{id: event.id}) |> hide("##{id}")}
                  data-confirm="Are you sure?"
                  class="btn btn-sm bg-red-100 text-red-600 border-none hover:bg-red-200"
                >
                  Delete
                </.link>
              </div>
            </div>

            <!-- Empty state -->
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

    events = list_events(socket.assigns.current_scope)
    now = NaiveDateTime.utc_now()

    {:ok,
     socket
     |> assign(:page_title, "Dashboard")
     |> assign(:total_events, length(events))
     |> assign(:has_events, length(events) > 0)
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

    {:noreply,
     socket
     |> assign(:total_events, length(events))
     |> assign(:has_events, length(events) > 0)
     |> assign(:upcoming_events, Enum.count(events, &(NaiveDateTime.compare(&1.start_time, now) == :gt)))
     |> assign(:past_events, Enum.count(events, &(NaiveDateTime.compare(&1.start_time, now) == :lt)))
     |> stream(:events, events, reset: true)}
  end

  defp list_events(current_scope) do
    Events.list_events(current_scope)
  end
end
