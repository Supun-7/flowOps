defmodule FlowopsWeb.MemberLive.Dashboard do
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

        <div class="max-w-4xl mx-auto p-6">

          <div class="mb-8 mt-4">
            <h1 class="text-3xl font-extrabold text-gray-800">My Member Dashboard 👷</h1>
            <p class="text-gray-500 mt-1">{@current_scope.user.email}</p>
          </div>

          <!-- Pending Invitations -->
          <div class="bg-white rounded-2xl shadow p-6 mb-6">
            <h2 class="text-xl font-bold text-gray-800 mb-4">
              Pending Invitations
              <span :if={length(@pending_invitations) > 0} class="ml-2 px-2 py-0.5 rounded-full bg-yellow-100 text-yellow-700 text-xs font-bold">
                {length(@pending_invitations)}
              </span>
            </h2>

            <div class="space-y-3">
              <div
                :for={invitation <- @pending_invitations}
                class="flex items-center justify-between bg-yellow-50 border border-yellow-100 rounded-xl p-4"
              >
                <div>
                  <p class="font-bold text-gray-800">{invitation.event.title}</p>
                  <p class="text-sm text-gray-500">Role: {invitation.role || "Not specified"}</p>
                  <p class="text-sm text-gray-500">Invited by: {invitation.invited_by_user.email}</p>
                  <p class="text-xs text-gray-400 mt-1">{invitation.event.start_time}</p>
                </div>
                <div class="flex gap-2">
                  <button
                    phx-click="accept_invitation"
                    phx-value-id={invitation.id}
                    class="px-4 py-2 rounded-xl bg-green-600 text-white text-sm font-bold hover:bg-green-700 transition"
                  >
                    Accept
                  </button>
                  <button
                    phx-click="decline_invitation"
                    phx-value-id={invitation.id}
                    class="px-4 py-2 rounded-xl bg-red-100 text-red-600 text-sm font-bold hover:bg-red-200 transition"
                  >
                    Decline
                  </button>
                </div>
              </div>

              <div :if={Enum.empty?(@pending_invitations)} class="text-center py-6 text-gray-400">
                <p>No pending invitations.</p>
              </div>
            </div>
          </div>

          <!-- My Assigned Events -->
          <div class="bg-white rounded-2xl shadow p-6">
            <h2 class="text-xl font-bold text-gray-800 mb-4">My Assigned Events</h2>

            <div class="space-y-4">
              <div
                :for={member <- @committee_assignments}
                class="bg-gray-50 rounded-xl p-5 border border-gray-100"
              >
                <div class="flex items-start justify-between mb-4">
                  <div>
                    <h3 class="text-lg font-bold text-gray-800">{member.event.title}</h3>
                    <p class="text-sm text-gray-500">📍 {member.event.location}</p>
                    <p class="text-sm text-gray-500">🕐 {member.event.start_time}</p>
                    <p class="text-sm text-purple-600 font-medium mt-1">
                      Role: {member.role || "Not specified"}
                    </p>
                  </div>
                  <span class={[
                    "px-3 py-1 rounded-full text-xs font-bold uppercase",
                    member.event.status == "live" && "bg-green-100 text-green-700",
                    member.event.status == "upcoming" && "bg-blue-100 text-blue-700",
                    member.event.status == "ended" && "bg-gray-100 text-gray-500"
                  ]}>
                    {member.event.status}
                  </span>
                </div>

                <!-- Current Status -->
                <div class="flex items-center gap-3 mb-4">
                  <span class={[
                    "px-3 py-1 rounded-full text-xs font-bold uppercase",
                    member.attendance_status == "present" && "bg-green-100 text-green-700",
                    member.attendance_status == "absent" && "bg-gray-100 text-gray-500",
                    member.attendance_status == "left" && "bg-red-100 text-red-600"
                  ]}>
                    {member.attendance_status}
                  </span>

                  <span :if={member.attendance_status == "present"} class={[
                    "px-3 py-1 rounded-full text-xs font-bold uppercase",
                    member.work_status == "available" && "bg-blue-100 text-blue-700",
                    member.work_status == "busy" && "bg-orange-100 text-orange-600"
                  ]}>
                    {member.work_status}
                  </span>
                </div>

                <!-- Action Buttons -->
                <div class="flex flex-wrap gap-2">
                  <button
                    :if={member.attendance_status == "absent"}
                    phx-click="mark_present"
                    phx-value-id={member.id}
                    class="px-4 py-2 rounded-xl bg-green-600 text-white text-sm font-bold hover:bg-green-700 transition"
                  >
                    ✅ Mark Present
                  </button>

                  <%= if member.attendance_status == "present" do %>
                    <button
                      phx-click="mark_left"
                      phx-value-id={member.id}
                      class="px-4 py-2 rounded-xl bg-red-500 text-white text-sm font-bold hover:bg-red-600 transition"
                    >
                      🚪 Mark Left
                    </button>
                    <button
                      :if={member.work_status == "available"}
                      phx-click="mark_busy"
                      phx-value-id={member.id}
                      class="px-4 py-2 rounded-xl bg-orange-500 text-white text-sm font-bold hover:bg-orange-600 transition"
                    >
                      🔴 Mark Busy
                    </button>
                    <button
                      :if={member.work_status == "busy"}
                      phx-click="mark_available"
                      phx-value-id={member.id}
                      class="px-4 py-2 rounded-xl bg-blue-500 text-white text-sm font-bold hover:bg-blue-600 transition"
                    >
                      🟢 Mark Available
                    </button>
                  <% end %>

                  <button
                    :if={member.attendance_status == "left"}
                    phx-click="mark_present"
                    phx-value-id={member.id}
                    class="px-4 py-2 rounded-xl bg-purple-600 text-white text-sm font-bold hover:bg-purple-700 transition"
                  >
                    🔄 Re-enter Premises
                  </button>
                </div>

              </div>

              <div :if={Enum.empty?(@committee_assignments)} class="text-center py-8 text-gray-400">
                <p class="text-lg font-medium">No assigned events yet.</p>
                <p class="text-sm mt-1">Accept an invitation to get started.</p>
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
    user_id = socket.assigns.current_scope.user.id

    if connected?(socket) do
      Invitations.subscribe_member(user_id)
    end

    events = Events.list_events(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, "Member Dashboard")
     |> assign(:has_events, length(events) > 0)
     |> assign(:has_assignments, length(Invitations.list_committee_assignments(user_id)) > 0)
     |> assign(:pending_invitations, Invitations.list_pending_invitations(user_id))
     |> assign(:committee_assignments, Invitations.list_committee_assignments(user_id))}
  end

  @impl true
  def handle_event("accept_invitation", %{"id" => id}, socket) do
    user_id = socket.assigns.current_scope.user.id

    case Invitations.accept_invitation(String.to_integer(id), user_id) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Invitation accepted!")
         |> assign(:pending_invitations, Invitations.list_pending_invitations(user_id))
         |> assign(:has_assignments, true)
         |> assign(:committee_assignments, Invitations.list_committee_assignments(user_id))}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not accept invitation.")}
    end
  end

  def handle_event("decline_invitation", %{"id" => id}, socket) do
    user_id = socket.assigns.current_scope.user.id

    case Invitations.decline_invitation(String.to_integer(id), user_id) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Invitation declined.")
         |> assign(:pending_invitations, Invitations.list_pending_invitations(user_id))}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not decline invitation.")}
    end
  end

  def handle_event("mark_present", %{"id" => id}, socket) do
    user_id = socket.assigns.current_scope.user.id
    Invitations.update_attendance(String.to_integer(id), "present")
    {:noreply, assign(socket, :committee_assignments, Invitations.list_committee_assignments(user_id))}
  end

  def handle_event("mark_left", %{"id" => id}, socket) do
    user_id = socket.assigns.current_scope.user.id
    Invitations.update_attendance(String.to_integer(id), "left")
    {:noreply, assign(socket, :committee_assignments, Invitations.list_committee_assignments(user_id))}
  end

  def handle_event("mark_busy", %{"id" => id}, socket) do
    user_id = socket.assigns.current_scope.user.id
    Invitations.update_work_status(String.to_integer(id), "busy")
    {:noreply, assign(socket, :committee_assignments, Invitations.list_committee_assignments(user_id))}
  end

  def handle_event("mark_available", %{"id" => id}, socket) do
    user_id = socket.assigns.current_scope.user.id
    Invitations.update_work_status(String.to_integer(id), "available")
    {:noreply, assign(socket, :committee_assignments, Invitations.list_committee_assignments(user_id))}
  end

  @impl true
  def handle_info({:member_updated, _event_id}, socket) do
    user_id = socket.assigns.current_scope.user.id
    {:noreply, assign(socket, :committee_assignments, Invitations.list_committee_assignments(user_id))}
  end
end
