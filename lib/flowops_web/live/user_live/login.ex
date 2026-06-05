defmodule FlowopsWeb.UserLive.Login do
  use FlowopsWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="fixed inset-0 flex overflow-hidden z-50">

        <!-- LEFT SIDE: Background image with overlay -->
        <div class="hidden lg:flex w-1/2 relative">
          <img
            src="https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=1200"
            class="absolute inset-0 w-full h-full object-cover"
          />
          <div class="absolute inset-0 bg-gradient-to-br from-violet-900/80 to-fuchsia-900/60"></div>
          <div class="relative z-10 flex flex-col justify-end p-12 text-white">
            <h2 class="text-4xl font-extrabold mb-3">Every great event starts with a plan.</h2>
            <p class="text-white/70 text-lg">FlowOps helps you organize, manage, and run events effortlessly.</p>
          </div>
        </div>

        <!-- RIGHT SIDE: Login form -->
        <div class="w-full lg:w-1/2 flex items-center justify-center bg-white px-8 py-12 overflow-y-auto">
          <div class="w-full max-w-md space-y-6">

            <!-- Logo -->
            <div class="flex flex-col items-center mb-6">
              <div class="bg-gradient-to-br from-violet-600 to-fuchsia-500 rounded-xl p-3 mb-3">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
              </div>
              <h1 class="text-2xl font-extrabold text-gray-800">Welcome back</h1>
              <p class="text-gray-500 text-sm mt-1">
                Don't have an account?
                <.link navigate={~p"/users/register"} class="text-violet-600 font-semibold hover:underline">
                  Sign up
                </.link>
              </p>
            </div>

            <!-- Flash messages -->
            <div :if={Phoenix.Flash.get(@flash, :error)} class="bg-red-50 border border-red-200 text-red-700 rounded-lg px-4 py-3 text-sm">
              {Phoenix.Flash.get(@flash, :error)}
            </div>
            <div :if={Phoenix.Flash.get(@flash, :info)} class="bg-blue-50 border border-blue-200 text-blue-700 rounded-lg px-4 py-3 text-sm">
              {Phoenix.Flash.get(@flash, :info)}
            </div>

            <!-- Login Form -->
            <.form
              :let={f}
              for={@form}
              id="login_form"
              action={~p"/users/log-in"}
              phx-submit="submit_password"
              phx-trigger-action={@trigger_submit}
              class="space-y-4"
            >
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                <.input
                  field={f[:email]}
                  type="email"
                  autocomplete="username"
                  spellcheck="false"
                  required
                  phx-mounted={JS.focus()}
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Password</label>
                <.input
                  field={@form[:password]}
                  type="password"
                  autocomplete="current-password"
                  spellcheck="false"
                  required
                />
              </div>
              <button type="submit" class="btn w-full bg-gradient-to-r from-violet-600 to-fuchsia-500 text-white border-none hover:opacity-90 text-base">
                Log In
              </button>
            </.form>

          </div>
        </div>

      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])

    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form, trigger_submit: false)}
  end

  @impl true
  def handle_event("submit_password", _params, socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end
end
