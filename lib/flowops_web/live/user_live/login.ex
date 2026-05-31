defmodule FlowopsWeb.UserLive.Login do
  use FlowopsWeb, :live_view

  alias Flowops.Accounts

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
                <%= if @current_scope do %>
                  Please reauthenticate to continue.
                <% else %>
                  Don't have an account?
                  <.link navigate={~p"/users/register"} class="text-violet-600 font-semibold hover:underline">
                    Sign up
                  </.link>
                <% end %>
              </p>
            </div>

            <!-- Dev mail notice -->
            <div :if={local_mail_adapter?()} class="bg-blue-50 border border-blue-200 text-blue-700 rounded-lg px-4 py-3 text-sm">
              You are running the local mail adapter.
              Visit <.link href="/dev/mailbox" class="underline font-semibold">the mailbox page</.link> to see sent emails.
            </div>

            <!-- Magic link form -->
            <.form :let={f} for={@form} id="login_form_magic" action={~p"/users/log-in"} phx-submit="submit_magic" class="space-y-3">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                <.input readonly={!!@current_scope} field={f[:email]} type="email" autocomplete="username" spellcheck="false" required phx-mounted={JS.focus()} />
              </div>
              <button type="submit" class="btn w-full bg-gradient-to-r from-violet-600 to-fuchsia-500 text-white border-none hover:opacity-90">
                Log in with email →
              </button>
            </.form>

            <div class="divider text-gray-400 text-xs">or</div>

            <!-- Password form -->
            <.form :let={f} for={@form} id="login_form_password" action={~p"/users/log-in"} phx-submit="submit_password" phx-trigger-action={@trigger_submit} class="space-y-3">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                <.input readonly={!!@current_scope} field={f[:email]} type="email" autocomplete="username" spellcheck="false" required />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Password</label>
                <.input field={@form[:password]} type="password" autocomplete="current-password" spellcheck="false" />
              </div>
              <button type="submit" name={@form[:remember_me].name} value="true" class="btn w-full bg-gradient-to-r from-violet-600 to-fuchsia-500 text-white border-none hover:opacity-90">
                Log in and stay logged in →
              </button>
              <button type="submit" class="btn w-full btn-outline border-violet-400 text-violet-600 hover:bg-violet-50">
                Log in only this time
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

  def handle_event("submit_magic", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_login_instructions(
        user,
        &url(~p"/users/log-in/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions for logging in shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> push_navigate(to: ~p"/users/log-in")}
  end

  defp local_mail_adapter? do
    Application.get_env(:flowops, Flowops.Mailer)[:adapter] == Swoosh.Adapters.Local
  end
end
