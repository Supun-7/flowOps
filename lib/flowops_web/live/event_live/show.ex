defmodule FlowopsWeb.EventLive.Show do
  use FlowopsWeb, :live_view
  alias Flowops.Events
  alias Flowops.Invitations
  alias FlowopsWeb.DashboardNav

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="fixed inset-0 top-0 bg-gray-50 overflow-y-auto z-40">

        <DashboardNav.dashboard_nav current_scope={@current_scope} />

        <div class="max-w-4xl mx-auto p-6">

          <!-- Back Button -->
          <div class="mt-4 mb-6">
            <.link navigate={~p"/events"} class="text-purple-600 hover:underline text-sm font-medium">
              ← Back to Dashboard
            </.link>
          </div>

          <!-- Event Header Card -->
          <div class="bg-white rounded-2xl shadow p-8 mb-6">
            <div class="flex items-start justify-between">
              <div>
                <div class="flex items-center gap-3 mb-2">
                  <h1 class="text-3xl font-extrabold text-gray-800">{@event.title}</h1>
                  <span class={[
                    "px-3 py-1 rounded-full text-xs font-bold uppercase",
                    @event.status == "live" && "bg-green-100 text-green-700",
                    @event.status == "upcoming" && "bg-blue-100 text-blue-700",
                    @event.status == "ended" && "bg-gray-100 text-gray-500"
                  ]}>
                    {@event.status}
                  </span>
                </div>
                <p class="text-gray-500 mt-1">{@event.description}</p>
              </div>
              <.link navigate={~p"/events/#{@event}/edit?return_to=show"} class="px-4 py-2 rounded-xl bg-purple-100 text-purple-700 text-sm font-bold hover:bg-purple-200 transition">
                Edit
              </.link>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mt-6">
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
                <p class="text-xs text-gray-400 uppercase font-semibold mb-1">Google Maps</p>
                <%= if @event.map_link do %>
                  <a href={@event.map_link} target="_blank" class="text-purple-600 hover:underline text-sm">
                    Open in Google Maps →
                  </a>
                <% else %>
                  <p class="text-gray-400 text-sm">No map link added</p>
                <% end %>
              </div>
            </div>
          </div>

          <!-- Invite Committee Member -->
          <div class="bg-white rounded-2xl shadow p-6 mb-6">
            <h2 class="text-xl font-bold text-gray-800 mb-4">Invite Committee Member</h2>
            <.form for={@invite_form} phx-submit="invite_member" class="flex gap-3 flex-wrap">
              <div class="flex-1 min-w-48">
                <input
                  type="email"
                  name="email"
                  placeholder="Enter member's email address..."
                  class="input input-bordered w-full"
                  required
                />
              </div>
              <div class="w-48">
                <input
                  type="text"
                  name="role"
                  placeholder="Role (e.g. Security)"
                  class="input input-bordered w-full"
                />
              </div>
              <button type="submit" class="px-4 py-2 rounded-xl bg-gradient-to-r from-purple-700 to-indigo-600 text-white text-sm font-bold hover:opacity-90 transition">
                Send Invite
              </button>
            </.form>
          </div>

          <!-- Invitations List -->
          <div class="bg-white rounded-2xl shadow p-6 mb-6">
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
              <div :if={Enum.empty?(@invitations)} class="text-center py-8 text-gray-400">
                <p>No invitations sent yet.</p>
              </div>
            </div>
          </div>

          <!-- Live Committee Members -->
          <div class="bg-white rounded-2xl shadow p-6">
            <div class="flex items-center gap-3 mb-4">
              <h2 class="text-xl font-bold text-gray-800">Live Committee Status</h2>
              <!-- Live indicator -->
              <span :if={@event.status == "live"} class="flex items-center gap-1 px-2 py-1 bg-green-100 text-green-700 text-xs font-bold rounded-full">
                <span class="w-2 h-2 bg-green-500 rounded-full animate-pulse"></span>
                LIVE
              </span>
            </div>

            <div class="space-y-3">
              <div :for={member <- @committee_members} class="flex items-center justify-between bg-gray-50 rounded-xl p-4">
                <div>
                  <p class="font-semibold text-gray-800">{member.user.email}</p>
                  <p class="text-sm text-gray-500">{member.role || "No role assigned"}</p>
                  <p :if={member.joined_at} class="text-xs text-gray-400 mt-1">
                    Joined at: {member.joined_at}
                  </p>
                </div>
                <div class="flex gap-2">
                  <span class={[
                    "px-3 py-1 rounded-full text-xs font-bold uppercase",
                    member.attendance_status == "present" && "bg-green-100 text-green-700",
                    member.attendance_status == "absent" && "bg-gray-100 text-gray-500",
                    member.attendance_status == "left" && "bg-red-100 text-red-600"
                  ]}>
                    {member.attendance_status}
                  </span>
                  <span class={[
                    "px-3 py-1 rounded-full text-xs font-bold uppercase",
                    member.work_status == "available" && "bg-blue-100 text-blue-700",
                    member.work_status == "busy" && "bg-orange-100 text-orange-600"
                  ]}>
                    {member.work_status}
                  </span>
                </div>
              </div>
              <div :if={Enum.empty?(@committee_members)} class="text-center py-8 text-gray-400">
                <p>No committee members yet.</p>
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
    end

    {:ok,
     socket
     |> assign(:page_title, event.title)
     |> assign(:event, event)
     |> assign(:invite_form, to_form(%{}, as: "invite"))
     |> assign(:invitations, Invitations.list_invitations(event.id))
     |> assign(:committee_members, Invitations.list_committee_members(event.id))}
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

  @impl true
  def handle_info({:member_updated, event_id}, socket) do
    {:noreply,
     assign(socket, :committee_members, Invitations.list_committee_members(event_id))}
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
