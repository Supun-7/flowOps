defmodule FlowopsWeb.MemberLive.Dashboard do
  use FlowopsWeb, :live_view
  alias Flowops.Events
  alias Flowops.Invitations
  alias Flowops.Tasks
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
              <div :for={invitation <- @pending_invitations} class="flex items-center justify-between bg-yellow-50 border border-yellow-100 rounded-xl p-4">
                <div>
                  <p class="font-bold text-gray-800">{invitation.event.title}</p>
                  <p class="text-sm text-gray-500">Role: {invitation.role || "Not specified"}</p>
                  <p class="text-sm text-gray-500">Invited by: {invitation.invited_by_user.email}</p>
                  <p class="text-xs text-gray-400 mt-1">{invitation.event.start_time}</p>
                </div>
                <div class="flex gap-2">
                  <button phx-click="accept_invitation" phx-value-id={invitation.id} class="px-4 py-2 rounded-xl bg-green-600 text-white text-sm font-bold hover:bg-green-700 transition">Accept</button>
                  <button phx-click="decline_invitation" phx-value-id={invitation.id} class="px-4 py-2 rounded-xl bg-red-100 text-red-600 text-sm font-bold hover:bg-red-200 transition">Decline</button>
                </div>
              </div>
              <div :if={Enum.empty?(@pending_invitations)} class="text-center py-6 text-gray-400">
                <p>No pending invitations.</p>
              </div>
            </div>
          </div>

          <!-- My Assigned Events -->
          <div class="space-y-6">
            <div :for={member <- @committee_assignments} class="bg-white rounded-2xl shadow overflow-hidden">

              <!-- Event Header -->
              <div class="bg-gradient-to-r from-purple-950 via-purple-800 to-indigo-900 p-6 text-white">
                <div class="flex items-start justify-between">
                  <div>
                    <h3 class="text-xl font-extrabold">{member.event.title}</h3>
                    <p class="text-white/70 text-sm mt-1">📍 {member.event.location}</p>
                    <p class="text-white/70 text-sm">🕐 {member.event.start_time}</p>
                    <p class="text-purple-300 text-sm font-medium mt-1">Role: {member.role || "Not specified"}</p>
                  </div>
                  <span class={[
                    "px-3 py-1 rounded-full text-xs font-bold uppercase",
                    member.event.status == "live" && "bg-green-400/20 text-green-300 border border-green-400/30",
                    member.event.status == "upcoming" && "bg-blue-400/20 text-blue-300 border border-blue-400/30",
                    member.event.status == "ended" && "bg-gray-400/20 text-gray-300 border border-gray-400/30"
                  ]}>
                    {member.event.status}
                  </span>
                </div>

                <!-- My Status Badges -->
                <div class="flex items-center gap-2 mt-4">
                  <span class={[
                    "px-3 py-1 rounded-full text-xs font-bold uppercase",
                    member.attendance_status == "present" && "bg-green-400/20 text-green-300",
                    member.attendance_status == "absent" && "bg-gray-400/20 text-gray-300",
                    member.attendance_status == "left" && "bg-red-400/20 text-red-300"
                  ]}>
                    {member.attendance_status}
                  </span>
                  <span :if={member.attendance_status == "present"} class={[
                    "px-3 py-1 rounded-full text-xs font-bold uppercase",
                    member.work_status == "available" && "bg-blue-400/20 text-blue-300",
                    member.work_status == "busy" && "bg-orange-400/20 text-orange-300"
                  ]}>
                    {member.work_status}
                  </span>
                </div>

                <!-- Action Buttons -->
                <div class="flex flex-wrap gap-2 mt-4">
                  <button :if={member.attendance_status == "absent"} phx-click="mark_present" phx-value-id={member.id} class="px-4 py-2 rounded-xl bg-green-500 text-white text-sm font-bold hover:bg-green-600 transition">
                    ✅ Mark Present
                  </button>
                  <%= if member.attendance_status == "present" do %>
                    <button phx-click="mark_left" phx-value-id={member.id} class="px-4 py-2 rounded-xl bg-red-500 text-white text-sm font-bold hover:bg-red-600 transition">
                      🚪 Mark Left
                    </button>
                    <button :if={member.work_status == "available"} phx-click="mark_busy" phx-value-id={member.id} class="px-4 py-2 rounded-xl bg-orange-500 text-white text-sm font-bold hover:bg-orange-600 transition">
                      🔴 Mark Busy
                    </button>
                    <button :if={member.work_status == "busy"} phx-click="mark_available" phx-value-id={member.id} class="px-4 py-2 rounded-xl bg-blue-500 text-white text-sm font-bold hover:bg-blue-600 transition">
                      🟢 Mark Available
                    </button>
                  <% end %>
                  <button :if={member.attendance_status == "left"} phx-click="mark_present" phx-value-id={member.id} class="px-4 py-2 rounded-xl bg-purple-500 text-white text-sm font-bold hover:bg-purple-600 transition">
                    🔄 Re-enter Premises
                  </button>
                </div>
              </div>

              <!-- Tasks + Map -->
              <div class="p-6">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">

                  <!-- My Tasks -->
                  <div>
                    <h4 class="font-bold text-gray-800 mb-3">My Tasks</h4>
                    <div class="space-y-2">
                      <div :for={task <- get_member_tasks(@tasks_by_event, member.event_id, member.user_id)} class="bg-gray-50 rounded-xl p-3">
                        <div class="flex items-center justify-between mb-2">
                          <p class={[
                            "text-sm font-medium",
                            task.status == "done" && "line-through text-gray-400",
                            task.status != "done" && "text-gray-800"
                          ]}>
                            {task.title}
                          </p>
                          <span class={[
                            "px-2 py-0.5 rounded-full text-xs font-bold uppercase",
                            task.status == "pending" && "bg-yellow-100 text-yellow-700",
                            task.status == "in_progress" && "bg-blue-100 text-blue-700",
                            task.status == "done" && "bg-green-100 text-green-700"
                          ]}>
                            {task.status}
                          </span>
                        </div>
                        <!-- Update task status buttons -->
                        <div class="flex gap-1 mt-2">
                          <button :if={task.status == "pending"} phx-click="update_task" phx-value-id={task.id} phx-value-status="in_progress" class="px-2 py-1 rounded-lg bg-blue-100 text-blue-700 text-xs font-bold hover:bg-blue-200 transition">
                            Start
                          </button>
                          <button :if={task.status == "in_progress"} phx-click="update_task" phx-value-id={task.id} phx-value-status="done" class="px-2 py-1 rounded-lg bg-green-100 text-green-700 text-xs font-bold hover:bg-green-200 transition">
                            Done ✓
                          </button>
                          <button :if={task.status == "done"} phx-click="update_task" phx-value-id={task.id} phx-value-status="pending" class="px-2 py-1 rounded-lg bg-gray-100 text-gray-600 text-xs font-bold hover:bg-gray-200 transition">
                            Reopen
                          </button>
                        </div>
                      </div>
                      <div :if={Enum.empty?(get_member_tasks(@tasks_by_event, member.event_id, member.user_id))} class="text-center py-4 text-gray-400 text-sm">
                        No tasks assigned yet.
                      </div>
                    </div>
                  </div>

                  <!-- Map -->
                  <div>
                    <h4 class="font-bold text-gray-800 mb-3">Event Location</h4>
                    <div class="rounded-xl overflow-hidden border border-gray-200 w-full h-40">
                      <iframe src={"https://www.openstreetmap.org/export/embed.html?query=#{URI.encode(member.event.location)}&layer=mapnik"} width="100%" height="100%" style="border:0;" loading="lazy" allowfullscreen></iframe>
                    </div>
                    <a href={"https://www.openstreetmap.org/search?query=#{URI.encode(member.event.location)}"} target="_blank" class="text-purple-600 hover:underline text-xs font-medium mt-1 block">
                      Open in OpenStreetMap →
                    </a>
                  </div>

                </div>
              </div>

            </div>

            <div :if={Enum.empty?(@committee_assignments)} class="bg-white rounded-2xl shadow p-8 text-center text-gray-400">
              <p class="text-lg font-medium">No assigned events yet.</p>
              <p class="text-sm mt-1">Accept an invitation to get started.</p>
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
    assignments = Invitations.list_committee_assignments(user_id)

    if connected?(socket) do
      Enum.each(assignments, fn member ->
        Tasks.subscribe_tasks(member.event_id)
      end)
    end

    tasks_by_event = assignments
    |> Enum.map(fn member ->
      {member.event_id, Tasks.list_tasks(member.event_id)}
    end)
    |> Map.new()

    {:ok,
     socket
     |> assign(:page_title, "Member Dashboard")
     |> assign(:has_events, length(events) > 0)
     |> assign(:has_assignments, length(assignments) > 0)
     |> assign(:pending_count, length(Invitations.list_pending_invitations(user_id)))
     |> assign(:pending_invitations, Invitations.list_pending_invitations(user_id))
     |> assign(:committee_assignments, assignments)
     |> assign(:tasks_by_event, tasks_by_event)}
  end

  defp get_member_tasks(tasks_by_event, event_id, user_id) do
    tasks_by_event
    |> Map.get(event_id, [])
    |> Enum.filter(&(&1.assigned_to_user_id == user_id))
  end

  @impl true
  def handle_event("accept_invitation", %{"id" => id}, socket) do
    user_id = socket.assigns.current_scope.user.id
    case Invitations.accept_invitation(String.to_integer(id), user_id) do
      {:ok, _} ->
        assignments = Invitations.list_committee_assignments(user_id)
        tasks_by_event = assignments |> Enum.map(fn m -> {m.event_id, Tasks.list_tasks(m.event_id)} end) |> Map.new()
        {:noreply,
         socket
         |> put_flash(:info, "Invitation accepted!")
         |> assign(:pending_invitations, Invitations.list_pending_invitations(user_id))
         |> assign(:pending_count, length(Invitations.list_pending_invitations(user_id)))
         |> assign(:has_assignments, true)
         |> assign(:committee_assignments, assignments)
         |> assign(:tasks_by_event, tasks_by_event)}
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
         |> assign(:pending_invitations, Invitations.list_pending_invitations(user_id))
         |> assign(:pending_count, length(Invitations.list_pending_invitations(user_id)))}
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

  def handle_event("update_task", %{"id" => id, "status" => status}, socket) do
    user_id = socket.assigns.current_scope.user.id
    Tasks.update_task_status(String.to_integer(id), status)
    assignments = Invitations.list_committee_assignments(user_id)
    tasks_by_event = assignments |> Enum.map(fn m -> {m.event_id, Tasks.list_tasks(m.event_id)} end) |> Map.new()
    {:noreply, assign(socket, :tasks_by_event, tasks_by_event)}
  end

  @impl true
  def handle_info({:member_updated, _event_id}, socket) do
    user_id = socket.assigns.current_scope.user.id
    {:noreply, assign(socket, :committee_assignments, Invitations.list_committee_assignments(user_id))}
  end

  def handle_info({:tasks_updated, event_id}, socket) do
    tasks_by_event = Map.put(socket.assigns.tasks_by_event, event_id, Tasks.list_tasks(event_id))
    {:noreply, assign(socket, :tasks_by_event, tasks_by_event)}
  end
end
