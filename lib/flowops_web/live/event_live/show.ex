defmodule FlowopsWeb.EventLive.Show do
  use FlowopsWeb, :live_view

  alias Flowops.Events

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Event {@event.id}
        <:subtitle>This is a event record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/events"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/events/#{@event}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit event
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@event.title}</:item>
        <:item title="Description">{@event.description}</:item>
        <:item title="Location">{@event.location}</:item>
        <:item title="Start time">{@event.start_time}</:item>
        <:item title="End time">{@event.end_time}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Events.subscribe_events(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Event")
     |> assign(:event, Events.get_event!(socket.assigns.current_scope, id))}
  end

  @impl true
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
