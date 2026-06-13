defmodule FlowopsWeb.AdminLive.Dashboard do
  use FlowopsWeb, :live_view
  import Ecto.Query
  alias Flowops.Repo
  alias Flowops.Accounts.User
  alias Flowops.Events.Event
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
          pending_count={@pending_count}
        />

        <div class="max-w-6xl mx-auto p-6">

          <!-- Header -->
          <div class="mb-8 mt-4">
            <div class="flex items-center gap-3">
              <h1 class="text-3xl font-extrabold text-gray-800">Admin Dashboard</h1>
              <span class="px-3 py-1 rounded-full bg-red-100 text-red-700 text-xs font-bold uppercase">
                Admin
              </span>
            </div>
            <p class="text-gray-500 mt-1">Full system overview and management</p>
          </div>

          <!-- Stats Cards -->
          <div class="grid grid-cols-1 sm:grid-cols-4 gap-4 mb-8">
            <div class="bg-white rounded-2xl shadow p-6 flex items-center gap-4">
              <div class="bg-purple-100 rounded-xl p-3">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-purple-700" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
              </div>
              <div>
                <p class="text-sm text-gray-500">Total Users</p>
                <p class="text-2xl font-bold text-gray-800">{@total_users}</p>
              </div>
            </div>

            <div class="bg-white rounded-2xl shadow p-6 flex items-center gap-4">
              <div class="bg-indigo-100 rounded-xl p-3">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-indigo-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
              </div>
              <div>
                <p class="text-sm text-gray-500">Total Events</p>
                <p class="text-2xl font-bold text-gray-800">{@total_events}</p>
              </div>
            </div>

            <div class="bg-white rounded-2xl shadow p-6 flex items-center gap-4">
              <div class="bg-green-100 rounded-xl p-3">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <div>
                <p class="text-sm text-gray-500">Live Events</p>
                <p class="text-2xl font-bold text-gray-800">{@live_events}</p>
              </div>
            </div>

            <div class="bg-white rounded-2xl shadow p-6 flex items-center gap-4">
              <div class="bg-orange-100 rounded-xl p-3">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-orange-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                </svg>
              </div>
              <div>
                <p class="text-sm text-gray-500">Admin Users</p>
                <p class="text-2xl font-bold text-gray-800">{@total_admins}</p>
              </div>
            </div>
          </div>

          <!-- Users Table -->
          <div class="bg-white rounded-2xl shadow p-6 mb-6">
            <h2 class="text-xl font-bold text-gray-800 mb-4">All Users</h2>
            <div class="space-y-3">
              <div :for={user <- @users} class="flex items-center justify-between bg-gray-50 rounded-xl p-4">
                <div class="flex items-center gap-3">
                  <div class="bg-purple-100 rounded-full p-2">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-purple-700" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                    </svg>
                  </div>
                  <div>
                    <p class="font-semibold text-gray-800">{user.email}</p>
                    <p class="text-xs text-gray-400">Joined: {user.inserted_at}</p>
                  </div>
                </div>
                <div class="flex items-center gap-2">
                  <span :if={user.is_admin} class="px-2 py-1 rounded-full bg-red-100 text-red-700 text-xs font-bold">
                    Admin
                  </span>
                  <span :if={!user.is_admin} class="px-2 py-1 rounded-full bg-gray-100 text-gray-600 text-xs font-bold">
                    User
                  </span>
                  <button
                    :if={!user.is_admin}
                    phx-click="delete_user"
                    phx-value-id={user.id}
                    data-confirm="Are you sure you want to delete this user?"
                    class="px-3 py-1 rounded-xl bg-red-100 text-red-600 text-sm font-medium hover:bg-red-200 transition"
                  >
                    Delete
                  </button>
                </div>
              </div>
            </div>
          </div>

          <!-- Events Table -->
          <div class="bg-white rounded-2xl shadow p-6">
            <h2 class="text-xl font-bold text-gray-800 mb-4">All Events</h2>
            <div class="space-y-3">
              <div :for={event <- @events} class="flex items-center justify-between bg-gray-50 rounded-xl p-4">
                <div>
                  <p class="font-semibold text-gray-800">{event.title}</p>
                  <p class="text-sm text-gray-500">📍 {event.location}</p>
                  <p class="text-xs text-gray-400 mt-1">🕐 {event.start_time}</p>
                </div>
                <div class="flex items-center gap-2">
                  <span class={[
                    "px-3 py-1 rounded-full text-xs font-bold uppercase",
                    event.status == "live" && "bg-green-100 text-green-700",
                    event.status == "upcoming" && "bg-blue-100 text-blue-700",
                    event.status == "ended" && "bg-gray-100 text-gray-500"
                  ]}>
                    {event.status}
                  </span>
                  <button
                    phx-click="delete_event"
                    phx-value-id={event.id}
                    data-confirm="Are you sure you want to delete this event?"
                    class="px-3 py-1 rounded-xl bg-red-100 text-red-600 text-sm font-medium hover:bg-red-200 transition"
                  >
                    Delete
                  </button>
                </div>
              </div>
              <div :if={Enum.empty?(@events)} class="text-center py-8 text-gray-400">
                <p>No events yet.</p>
              </div>
            </div>
          </div>

        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user

    if !user.is_admin do
      {:ok,
       socket
       |> put_flash(:error, "You are not authorized to access this page.")
       |> push_navigate(to: ~p"/events")}
    else
      user_id = user.id
      users = Repo.all(from u in User, order_by: [asc: u.inserted_at])
      events = Repo.all(from e in Event, order_by: [desc: e.inserted_at])

      {:ok,
       socket
       |> assign(:page_title, "Admin Dashboard")
       |> assign(:has_events, true)
       |> assign(:has_assignments, false)
       |> assign(:pending_count, 0)
       |> assign(:users, users)
       |> assign(:events, events)
       |> assign(:total_users, length(users))
       |> assign(:total_events, length(events))
       |> assign(:live_events, Enum.count(events, &(&1.status == "live")))
       |> assign(:total_admins, Enum.count(users, &(&1.is_admin == true)))}
    end
  end

  @impl true
  def handle_event("delete_user", %{"id" => id}, socket) do
    user = Repo.get!(User, id)

    if user.is_admin do
      {:noreply, put_flash(socket, :error, "Cannot delete admin users.")}
    else
      Repo.delete!(user)
      users = Repo.all(from u in User, order_by: [asc: u.inserted_at])
      {:noreply,
       socket
       |> put_flash(:info, "User deleted successfully.")
       |> assign(:users, users)
       |> assign(:total_users, length(users))}
    end
  end

  def handle_event("delete_event", %{"id" => id}, socket) do
    event = Repo.get!(Event, id)
    Repo.delete!(event)
    events = Repo.all(from e in Event, order_by: [desc: e.inserted_at])
    {:noreply,
     socket
     |> put_flash(:info, "Event deleted successfully.")
     |> assign(:events, events)
     |> assign(:total_events, length(events))
     |> assign(:live_events, Enum.count(events, &(&1.status == "live")))}
  end
end
