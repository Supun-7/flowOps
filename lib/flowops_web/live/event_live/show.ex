defmodule FlowopsWeb.EventLive.Show do
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

        <div class="max-w-6xl mx-auto p-6">

          <div class="mt-4 mb-6">
            <.link navigate={~p"/events"} class="text-purple-600 hover:underline text-sm font-medium">
              ← Back to Dashboard
            </.link>
          </div>

          <!-- Event Header -->
          <div class="bg-gradient-to-r from-purple-950 via-purple-800 to-indigo-900 rounded-2xl shadow p-8 mb-6 text-white">
            <div class="flex items-start justify-between">
              <div>
                <div class="flex items-center gap-3 mb-2">
                  <h1 class="text-3xl font-extrabold">{@event.title}</h1>
                  <span class={[
                    "px-3 py-1 rounded-full text-xs font-bold uppercase",
                    @event.status == "live" && "bg-green-400/20 text-green-300 border border-green-400/30",
                    @event.status == "upcoming" && "bg-blue-400/20 text-blue-300 border border-blue-400/30",
                    @event.status == "ended" && "bg-gray-400/20 text-gray-300 border border-gray-400/30"
                  ]}>
                    <%= if @event.status == "live" do %>
                      <span class="inline-block w-2 h-2 bg-green-400 rounded-full animate-pulse mr-1"></span>
                    <% end %>
                    {@event.status}
                  </span>
                </div>
                <p class="text-white/70">{@event.description}</p>
              </div>
              <.link navigate={~p"/events/#{@event}/edit?return_to=show"} class="px-4 py-2 rounded-xl bg-white/10 text-white text-sm font-bold hover:bg-white/20 transition">
                Edit Event
              </.link>
            </div>

            <!-- Quick Stats -->
            <div class="grid grid-cols-2 sm:grid-cols-4 gap-4 mt-6">
              <div class="bg-white/10 rounded-xl p-4 text-center">
                <p class="text-2xl font-extrabold">{@total_members}</p>
                <p class="text-white/70 text-xs mt-1">Total Members</p>
              </div>
              <div class="bg-green-400/20 rounded-xl p-4 text-center border border-green-400/20">
                <p class="text-2xl font-extrabold text-green-300">{@present_members}</p>
                <p class="text-green-300/70 text-xs mt-1">Present</p>
              </div>
              <div class="bg-blue-400/20 rounded-xl p-4 text-center border border-blue-400/20">
                <p class="text-2xl font-extrabold text-blue-300">{@available_members}</p>
                <p class="text-blue-300/70 text-xs mt-1">Available</p>
              </div>
              <div class="bg-orange-400/20 rounded-xl p-4 text-center border border-orange-400/20">
                <p class="text-2xl font-extrabold text-orange-300">{@busy_members}</p>
                <p class="text-orange-300/70 text-xs mt-1">Busy</p>
              </div>
            </div>
          </div>

          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">

            <!-- Live Member Status -->
            <div class="bg-white rounded-2xl shadow p-6">
              <div class="flex items-center gap-3 mb-4">
                <h2 class="text-xl font-bold text-gray-800">Live Member Status</h2>
                <span :if={@event.status == "live"} class="flex items-center gap-1 px-2 py-1 bg-green-100 text-green-700 text-xs font-bold rounded-full">
                  <span class="w-2 h-2 bg-green-500 rounded-full animate-pulse"></span>
                  LIVE
                </span>
              </div>
              <div class="space-y-3">
                <div :for={member <- @committee_members} class="bg-gray-50 rounded-xl p-3">
                  <div class="flex items-center justify-between mb-2">
                    <div>
                      <p class="font-semibold text-gray-800 text-sm">{member.user.email}</p>
                      <p class="text-xs text-gray-500">{member.role || "No role"}</p>
                    </div>
                    <div class="flex gap-1">
                      <span class={[
                        "px-2 py-0.5 rounded-full text-xs font-bold uppercase",
                        member.attendance_status == "present" && "bg-green-100 text-green-700",
                        member.attendance_status == "absent" && "bg-gray-100 text-gray-500",
                        member.attendance_status == "left" && "bg-red-100 text-red-600"
                      ]}>
                        {member.attendance_status}
                      </span>
                      <span :if={member.attendance_status == "present"} class={[
                        "px-2 py-0.5 rounded-full text-xs font-bold uppercase",
                        member.work_status == "available" && "bg-blue-100 text-blue-700",
                        member.work_status == "busy" && "bg-orange-100 text-orange-600"
                      ]}>
                        {member.work_status}
                      </span>
                    </div>
                  </div>
                  <!-- Contribution bar -->
                  <div class="mt-2">
                    <div class="flex justify-between text-xs text-gray-400 mb-1">
                      <span>Tasks</span>
                      <span>{member_task_count(@tasks, member.user_id)} assigned</span>
                    </div>
                    <div class="w-full bg-gray-200 rounded-full h-1.5">
                      <div
                        class="bg-gradient-to-r from-purple-600 to-indigo-600 h-1.5 rounded-full transition-all"
                        style={"width: #{member_task_percentage(@tasks, member.user_id)}%"}
                      ></div>
                    </div>
                  </div>
                </div>
                <div :if={Enum.empty?(@committee_members)} class="text-center py-6 text-gray-400 text-sm">
                  No committee members yet.
                </div>
              </div>
            </div>

            <!-- Task Management -->
            <div class="bg-white rounded-2xl shadow p-6">
              <h2 class="text-xl font-bold text-gray-800 mb-4">Task Management</h2>

              <!-- Add Task Form -->
              <.form for={@task_form} phx-submit="add_task" class="mb-4">
                <div class="flex gap-2">
                  <select name="assigned_to_user_id" class="select select-bordered text-sm flex-shrink-0 w-36">
                    <option value="">Assign to...</option>
                    <option :for={member <- @committee_members} value={member.user_id}>
                      {String.split(member.user.email, "@") |> List.first()}
                    </option>
                  </select>
                  <input
                    type="text"
                    name="title"
                    placeholder="Add a task..."
                    class="input input-bordered w-full text-sm"
                    required
                  />
                  <button type="submit" class="px-4 py-2 rounded-xl bg-gradient-to-r from-purple-700 to-indigo-600 text-white text-sm font-bold hover:opacity-90 transition flex-shrink-0">
                    Add
                  </button>
                </div>
              </.form>

              <!-- Tasks List -->
              <div class="space-y-2 max-h-80 overflow-y-auto">
                <div :for={task <- @tasks} class="flex items-center justify-between bg-gray-50 rounded-xl p-3">
                  <div class="flex-1 min-w-0">
                    <p class={[
                      "text-sm font-medium truncate",
                      task.status == "done" && "line-through text-gray-400",
                      task.status != "done" && "text-gray-800"
                    ]}>
                      {task.title}
                    </p>
                    <p class="text-xs text-gray-400 mt-0.5">
                      {if task.assigned_to_user, do: task.assigned_to_user.email, else: "Unassigned"}
                    </p>
                  </div>
                  <span class={[
                    "px-2 py-0.5 rounded-full text-xs font-bold uppercase ml-2 flex-shrink-0",
                    task.status == "pending" && "bg-yellow-100 text-yellow-700",
                    task.status == "in_progress" && "bg-blue-100 text-blue-700",
                    task.status == "done" && "bg-green-100 text-green-700"
                  ]}>
                    {task.status}
                  </span>
                </div>
                <div :if={Enum.empty?(@tasks)} class="text-center py-6 text-gray-400 text-sm">
                  No tasks yet. Add one above.
                </div>
              </div>
            </div>

          </div>

          <!-- Event Details + Map -->
          <div class="bg-white rounded-2xl shadow p-6 mb-6">
            <h2 class="text-xl font-bold text-gray-800 mb-4">Event Details</h2>
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div class="bg-gray-50 rounded-xl p-4">
                <p class="text-xs text-gray-400 uppercase font-semibold mb-1">Location</p>
                <p class="text-gray-700 font-medium">{@event.location}</p>
              </div>
              <div class="bg-gray-50 rounded-xl p-4">
                <p class="text-xs text-gray-400 uppercase font-semibold mb-1">Start Time</p>
                <p class="text-gray-700 font-medium">{@event.start_time}</p>
              </div>
              <div class="bg-gray-50 rounded-xl p-4">
                <p class="text-xs text-gray-400 uppercase font-semibold mb-1">End Time</p>
                <p class="text-gray-700 font-medium">{@event.end_time}</p>
              </div>
              <div class="bg-gray-50 rounded-xl p-4">
                <p class="text-xs text-gray-400 uppercase font-semibold mb-1">Capacity</p>
                <p class="text-gray-700 font-medium">{@event.capacity || "Not set"}</p>
              </div>
              <div class="bg-gray-50 rounded-xl p-4 sm:col-span-2">
                <p class="text-xs text-gray-400 uppercase font-semibold mb-3">Location Map</p>
                <div class="rounded-xl overflow-hidden border border-gray-200 w-full h-48">
                  <iframe src={"https://www.openstreetmap.org/export/embed.html?query=#{URI.encode(@event.location)}&layer=mapnik"} width="100%" height="100%" style="border:0;" loading="lazy" allowfullscreen></iframe>
                </div>
                <div class="flex items-center justify-between mt-2">
                  <p class="text-xs text-gray-400">📍 {@event.location}</p>
                  <a href={"https://www.openstreetmap.org/search?query=#{URI.encode(@event.location)}"} target="_blank" class="text-purple-600 hover:underline text-xs font-medium">
                    Open in OpenStreetMap →
                  </a>
                </div>
              </div>
            </div>
          </div>

          <!-- Invite Committee Member -->
          <div class="bg-white rounded-2xl shadow p-6 mb-6">
            <h2 class="text-xl font-bold text-gray-800 mb-4">Invite Committee Member</h2>
            <.form for={@invite_form} phx-submit="invite_member" class="flex gap-3 flex-wrap">
              <div class="flex-1 min-w-48">
                <input type="email" name="email" placeholder="Enter member's email address..." class="input input-bordered w-full" required />
              </div>
              <div class="w-48">
                <input type="text" name="role" placeholder="Role (e.g. Security)" class="input input-bordered w-full" />
              </div>
              <button type="submit" class="px-4 py-2 rounded-xl bg-gradient-to-r from-purple-700 to-indigo-600 text-white text-sm font-bold hover:opacity-90 transition">
                Send Invite
              </button>
            </.form>
          </div>

          <!-- Invitations -->
          <div class="bg-white rounded-2xl shadow p-6">
            <h2 class="text-xl font-bold text-gray-800 mb-4">Invitations</h2>
            <div class="space-y-3">
              <div :for={invitation <- @invitations} class="flex items-center justify-between bg-gray-50 rounded-xl p-4">
                <div>
                  <p class="font-semibold text-gray-800">{invitation.invited_user.email}</p>
                  <p class="text-sm text-gray-500">{invitation.role || "No role assigned"}</p>
                </div>
                <span class={[
                  "px-3 py-1 rounded-full text-xs font-bold uppercase",
                  invitation.status == "pending" && "bg-yellow-100 text-yellow-700",
                  invitation.status == "accepted" && "bg-green-100 text-green-700",
                  invitation.status == "declined" && "bg-red-100 text-red-600"
                ]}>
                  {invitation.status}
                </span>
              </div>
              <div :if={Enum.empty?(@invitations)} class="text-center py-6 text-gray-400 text-sm">
                No invitations sent yet.
              </div>
            </div>
          </div>

        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    event = Events.get_event!(socket.assigns.current_scope, id)

    if connected?(socket) do
      Events.subscribe_events(socket.assigns.current_scope)
      Invitations.subscribe_event(event.id)
      Tasks.subscribe_tasks(event.id)
    end

    user_id = socket.assigns.current_scope.user.id
    events = Events.list_events(socket.assigns.current_scope)
    members = Invitations.list_committee_members(event.id)
    tasks = Tasks.list_tasks(event.id)

    {:ok,
     socket
     |> assign(:page_title, event.title)
     |> assign(:event, event)
     |> assign(:invite_form, to_form(%{}, as: "invite"))
     |> assign(:task_form, to_form(%{}, as: "task"))
     |> assign(:invitations, Invitations.list_invitations(event.id))
     |> assign(:committee_members, members)
     |> assign(:tasks, tasks)
     |> assign(:has_events, length(events) > 0)
     |> assign(:has_assignments, length(Invitations.list_committee_assignments(user_id)) > 0)
     |> assign(:pending_count, length(Invitations.list_pending_invitations(user_id)))
     |> assign_member_stats(members)}
  end

  defp assign_member_stats(socket, members) do
    socket
    |> assign(:total_members, length(members))
    |> assign(:present_members, Enum.count(members, &(&1.attendance_status == "present")))
    |> assign(:available_members, Enum.count(members, &(&1.attendance_status == "present" && &1.work_status == "available")))
    |> assign(:busy_members, Enum.count(members, &(&1.attendance_status == "present" && &1.work_status == "busy")))
  end

  defp member_task_count(tasks, user_id) do
    Enum.count(tasks, &(&1.assigned_to_user_id == user_id))
  end

  defp member_task_percentage(tasks, user_id) do
    total = length(tasks)
    if total == 0, do: 0, else: round(member_task_count(tasks, user_id) / total * 100)
  end

  @impl true
  def handle_event("invite_member", %{"email" => email, "role" => role}, socket) do
    event = socket.assigns.event
    current_user = socket.assigns.current_scope.user

    case Invitations.invite_user(event, email, role, current_user) do
      {:ok, _invitation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Invitation sent to #{email}")
         |> assign(:invitations, Invitations.list_invitations(event.id))}

      {:error, :user_not_found} ->
        {:noreply, put_flash(socket, :error, "No FlowOps account found for #{email}")}

      {:error, changeset} ->
        {:noreply, put_flash(socket, :error, "Could not send invitation: #{inspect(changeset)}")}
    end
  end

  def handle_event("add_task", %{"title" => title, "assigned_to_user_id" => assigned_to}, socket) do
    event = socket.assigns.event
    current_user = socket.assigns.current_scope.user

    assigned_to_user_id = case assigned_to do
      "" -> nil
      id -> String.to_integer(id)
    end

    case Tasks.create_task(%{
      event_id: event.id,
      created_by_user_id: current_user.id,
      assigned_to_user_id: assigned_to_user_id,
      title: title,
      status: "pending"
    }) do
      {:ok, _task} ->
        {:noreply,
         socket
         |> assign(:tasks, Tasks.list_tasks(event.id))
         |> assign(:task_form, to_form(%{}, as: "task"))}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not add task.")}
    end
  end

  @impl true
  def handle_info({:member_updated, event_id}, socket) do
    members = Invitations.list_committee_members(event_id)
    {:noreply,
     socket
     |> assign(:committee_members, members)
     |> assign_member_stats(members)}
  end

  def handle_info({:tasks_updated, event_id}, socket) do
    {:noreply, assign(socket, :tasks, Tasks.list_tasks(event_id))}
  end

  def handle_info(
        {:updated, %Flowops.Events.Event{id: id} = event},
        %{assigns: %{event: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :event, event)}
  end

  def handle_info(
        {:deleted, %Flowops.Events.Event{id: id}},
        %{assigns: %{event: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current event was deleted.")
     |> push_navigate(to: ~p"/events")}
  end

  def handle_info({type, %Flowops.Events.Event{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
