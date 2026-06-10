defmodule FlowopsWeb.EventLive.Form do
  use FlowopsWeb, :live_view
  alias Flowops.Events
  alias Flowops.Events.Event
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
            <h1 class="text-3xl font-extrabold text-gray-800">{@page_title}</h1>
            <p class="text-gray-500 mt-1">Fill in the details below to set up your event.</p>
          </div>

          <div class="bg-white rounded-2xl shadow p-8">
            <.form for={@form} id="event-form" phx-change="validate" phx-submit="save" class="space-y-6">

              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Event Title *</label>
                <.input field={@form[:title]} type="text" placeholder="e.g. Annual Tech Conference 2026" />
              </div>

              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Description</label>
                <.input field={@form[:description]} type="textarea" placeholder="Tell people what this event is about..." />
              </div>

              <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-1">Location *</label>
                  <.input field={@form[:location]} type="text" placeholder="e.g. Colombo, Sri Lanka" />
                  <p class="text-xs text-gray-400 mt-1">This will be used to show the map automatically.</p>
                </div>
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-1">Capacity</label>
                  <.input field={@form[:capacity]} type="number" placeholder="e.g. 500" />
                </div>
              </div>

              <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-1">Start Time *</label>
                  <.input field={@form[:start_time]} type="datetime-local" />
                </div>
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-1">End Time *</label>
                  <.input field={@form[:end_time]} type="datetime-local" />
                </div>
              </div>

              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Cover Image URL</label>
                <.input field={@form[:cover_image]} type="text" placeholder="Paste an image URL for your event cover..." />
                <p class="text-xs text-gray-400 mt-1">Paste any image URL. Leave empty to use default.</p>
              </div>

              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Event Status</label>
                <.input field={@form[:status]} type="select" options={[{"Upcoming", "upcoming"}, {"Live", "live"}, {"Ended", "ended"}]} />
              </div>

              <div class="flex gap-3 pt-2">
                <button type="submit" phx-disable-with="Saving..." class="px-6 py-2 rounded-xl bg-gradient-to-r from-purple-700 to-indigo-600 text-white font-bold hover:opacity-90 transition">
                  Save Event
                </button>
                <.link navigate={return_path(@current_scope, @return_to, @event)} class="px-6 py-2 rounded-xl border border-gray-300 text-gray-600 hover:bg-gray-50 transition">
                  Cancel
                </.link>
              </div>

            </.form>
          </div>

        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    user_id = socket.assigns.current_scope.user.id
    events = Events.list_events(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:has_events, length(events) > 0)
     |> assign(:has_assignments, length(Invitations.list_committee_assignments(user_id)) > 0)
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    event = Events.get_event!(socket.assigns.current_scope, id)
    socket
    |> assign(:page_title, "Edit Event")
    |> assign(:event, event)
    |> assign(:form, to_form(Events.change_event(socket.assigns.current_scope, event)))
  end

  defp apply_action(socket, :new, _params) do
    event = %Event{user_id: socket.assigns.current_scope.user.id}
    socket
    |> assign(:page_title, "New Event")
    |> assign(:event, event)
    |> assign(:form, to_form(Events.change_event(socket.assigns.current_scope, event)))
  end

  @impl true
  def handle_event("validate", %{"event" => event_params}, socket) do
    changeset = Events.change_event(socket.assigns.current_scope, socket.assigns.event, event_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"event" => event_params}, socket) do
    save_event(socket, socket.assigns.live_action, event_params)
  end

  defp save_event(socket, :edit, event_params) do
    case Events.update_event(socket.assigns.current_scope, socket.assigns.event, event_params) do
      {:ok, event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event updated successfully")
         |> push_navigate(to: return_path(socket.assigns.current_scope, socket.assigns.return_to, event))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_event(socket, :new, event_params) do
    case Events.create_event(socket.assigns.current_scope, event_params) do
      {:ok, event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event created successfully")
         |> push_navigate(to: return_path(socket.assigns.current_scope, socket.assigns.return_to, event))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _event), do: ~p"/events"
  defp return_path(_scope, "show", event), do: ~p"/events/#{event}"
end
