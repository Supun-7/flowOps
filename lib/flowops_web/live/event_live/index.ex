defmodule FlowopsWeb.EventLive.Index do
  use FlowopsWeb, :live_view

  alias Flowops.Events

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Events
        <:actions>
          <.button variant="primary" navigate={~p"/events/new"}>
            <.icon name="hero-plus" /> New Event
          </.button>
        </:actions>
      </.header>

      <.table
        id="events"
        rows={@streams.events}
        row_click={fn {_id, event} -> JS.navigate(~p"/events/#{event}") end}
      >
        <:col :let={{_id, event}} label="Title">{event.title}</:col>
        <:col :let={{_id, event}} label="Description">{event.description}</:col>
        <:col :let={{_id, event}} label="Location">{event.location}</:col>
        <:col :let={{_id, event}} label="Start time">{event.start_time}</:col>
        <:col :let={{_id, event}} label="End time">{event.end_time}</:col>
        <:action :let={{_id, event}}>
          <div class="sr-only">
            <.link navigate={~p"/events/#{event}"}>Show</.link>
          </div>
          <.link navigate={~p"/events/#{event}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, event}}>
          <.link
            phx-click={JS.push("delete", value: %{id: event.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Events.subscribe_events(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Events")
     |> stream(:events, list_events(socket.assigns.current_scope))}
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
    {:noreply, stream(socket, :events, list_events(socket.assigns.current_scope), reset: true)}
  end

  defp list_events(current_scope) do
    Events.list_events(current_scope)
  end
end
