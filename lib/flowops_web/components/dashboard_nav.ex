defmodule FlowopsWeb.DashboardNav do
  use FlowopsWeb, :html

  attr :current_scope, :any, required: true

  def dashboard_nav(assigns) do
    ~H"""
    <nav class="w-full flex items-center justify-between px-6 py-4 bg-gradient-to-r from-purple-950 via-purple-800 to-indigo-900 shadow-lg">

      <!-- Logo -->
      <a href="/events" class="flex items-center gap-2 text-white font-extrabold text-xl">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
        </svg>
        FlowOps
      </a>

      <!-- Middle Links -->
      <div class="hidden md:flex items-center gap-8">
        <a href="/events" class="text-slate-300 hover:text-white font-medium text-sm transition">
          Dashboard
        </a>
        <a href="/events?filter=live" class="text-slate-300 hover:text-white font-medium text-sm transition">
          Live Events
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
