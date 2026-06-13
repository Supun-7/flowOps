defmodule FlowopsWeb.DashboardNav do
  use FlowopsWeb, :html

  attr :current_scope, :any, required: true
  attr :has_events, :boolean, default: false
  attr :has_assignments, :boolean, default: false
  attr :pending_count, :integer, default: 0

  def dashboard_nav(assigns) do
    ~H"""
    <nav class="w-full flex items-center justify-between px-6 py-4 bg-gradient-to-r from-purple-950 via-purple-800 to-indigo-900 shadow-lg">

      <!-- Logo -->
      <a href="/" class="flex items-center gap-2 text-white font-extrabold text-xl">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
        </svg>
        FlowOps
      </a>

      <!-- Middle Links -->
      <div class="hidden md:flex items-center gap-8">
        <a :if={@has_events} href="/events" class="text-slate-300 hover:text-white font-medium text-sm transition">
          My Events
        </a>
        <a :if={@has_assignments} href="/member/dashboard" class="text-slate-300 hover:text-white font-medium text-sm transition">
          My Assignments
        </a>
        <a href="/events/new" class="text-slate-300 hover:text-white font-medium text-sm transition">
          New Event
        </a>
        <a href="/users/settings" class="text-slate-300 hover:text-white font-medium text-sm transition">
          Settings
        </a>
      </div>

      <!-- Right Side -->
      <div class="flex items-center gap-3">

        <!-- Dark/Light Toggle -->
        <button
          onclick="
            const current = document.documentElement.getAttribute('data-theme');
            const next = current === 'dark' ? 'light' : 'dark';
            document.documentElement.setAttribute('data-theme', next);
            localStorage.setItem('phx:theme', next);
          "
          class="p-2 rounded-xl bg-white/10 text-slate-300 hover:bg-white/20 hover:text-white transition"
          title="Toggle dark/light mode"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364-6.364l-.707.707M6.343 17.657l-.707.707M17.657 17.657l-.707.707M6.343 6.343l-.707.707M12 7a5 5 0 100 10A5 5 0 0012 7z" />
          </svg>
        </button>

        <!-- Bell Notification Icon -->
        <div class="relative">
          <button
            onclick="
              const dropdown = document.getElementById('notification-dropdown');
              dropdown.classList.toggle('hidden');
            "
            class="p-2 rounded-xl bg-white/10 text-slate-300 hover:bg-white/20 hover:text-white transition relative"
            title="Notifications"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
            </svg>
            <span :if={@pending_count > 0} class="absolute -top-1 -right-1 bg-red-500 text-white text-xs font-bold rounded-full h-4 w-4 flex items-center justify-center">
              {@pending_count}
            </span>
          </button>

          <!-- Notification Dropdown -->
          <div id="notification-dropdown" class="hidden absolute right-0 mt-2 w-80 bg-white rounded-2xl shadow-xl border border-gray-100 z-50">
            <div class="p-4 border-b border-gray-100">
              <h3 class="font-bold text-gray-800 text-sm">Pending Invitations</h3>
            </div>
            <%= if @pending_count == 0 do %>
              <div class="p-4 text-center text-gray-400 text-sm">
                No pending invitations
              </div>
            <% else %>
              <div class="p-3">
                <a href="/member/dashboard" class="block w-full text-center px-4 py-2 rounded-xl bg-gradient-to-r from-purple-700 to-indigo-600 text-white text-sm font-bold hover:opacity-90 transition">
                  View {@pending_count} Pending Invitation(s)
                </a>
              </div>
            <% end %>
            <div class="p-3 border-t border-gray-100">
              <a href="/member/dashboard" class="text-purple-600 hover:underline text-xs font-medium">
                Go to My Assignments →
              </a>
            </div>
          </div>
        </div>

        <span class="text-slate-300 text-sm hidden sm:block">
          {@current_scope.user.email}
        </span>

        <.link href={~p"/users/log-out"} method="delete" class="px-4 py-2 rounded-xl bg-white text-purple-900 text-sm font-bold hover:bg-slate-100 transition">
          Log out
        </.link>

      </div>
    </nav>
    """
  end
end
