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

            <%!-- Demo Credentials Section --%>
            <div class="mt-8 pt-6 border-t border-gray-200">
              <div class="flex items-center gap-2 mb-4">
                <div class="bg-amber-100 rounded-lg p-1.5">
                  <.icon name="hero-sparkles-solid" class="size-4 text-amber-600" />
                </div>
                <h3 class="text-sm font-bold text-gray-700">Try Demo Accounts</h3>
              </div>
              <p class="text-xs text-gray-400 mb-3">Click any account below to auto-fill credentials</p>

              <div class="space-y-2" id="demo-credentials" phx-hook=".FillCredentials">
                <button
                  type="button"
                  class="demo-cred-btn w-full flex items-center gap-3 px-3 py-2.5 rounded-xl border border-violet-200 bg-violet-50 hover:bg-violet-100 transition-all cursor-pointer group"
                  data-email="admin@gmail.com"
                  data-password="Demo@2024Secure!"
                >
                  <span class="flex items-center justify-center w-8 h-8 rounded-full bg-gradient-to-br from-violet-600 to-fuchsia-500 text-white text-xs font-bold shrink-0">👑</span>
                  <div class="text-left">
                    <p class="text-sm font-semibold text-gray-800 group-hover:text-violet-700">admin@gmail.com</p>
                    <p class="text-xs text-gray-400">Admin — Event Organizer</p>
                  </div>
                  <.icon name="hero-arrow-right-circle" class="size-5 text-violet-300 group-hover:text-violet-500 ml-auto transition-colors" />
                </button>

                <button
                  type="button"
                  class="demo-cred-btn w-full flex items-center gap-3 px-3 py-2.5 rounded-xl border border-gray-200 bg-gray-50 hover:bg-gray-100 transition-all cursor-pointer group"
                  data-email="sarah@flowops.com"
                  data-password="Demo@2024Secure!"
                >
                  <span class="flex items-center justify-center w-8 h-8 rounded-full bg-gradient-to-br from-emerald-500 to-teal-500 text-white text-xs font-bold shrink-0">S</span>
                  <div class="text-left">
                    <p class="text-sm font-semibold text-gray-800 group-hover:text-violet-700">sarah@flowops.com</p>
                    <p class="text-xs text-gray-400">Committee Member</p>
                  </div>
                  <.icon name="hero-arrow-right-circle" class="size-5 text-gray-300 group-hover:text-violet-500 ml-auto transition-colors" />
                </button>

                <button
                  type="button"
                  class="demo-cred-btn w-full flex items-center gap-3 px-3 py-2.5 rounded-xl border border-gray-200 bg-gray-50 hover:bg-gray-100 transition-all cursor-pointer group"
                  data-email="james@flowops.com"
                  data-password="Demo@2024Secure!"
                >
                  <span class="flex items-center justify-center w-8 h-8 rounded-full bg-gradient-to-br from-blue-500 to-indigo-500 text-white text-xs font-bold shrink-0">J</span>
                  <div class="text-left">
                    <p class="text-sm font-semibold text-gray-800 group-hover:text-violet-700">james@flowops.com</p>
                    <p class="text-xs text-gray-400">Committee Member</p>
                  </div>
                  <.icon name="hero-arrow-right-circle" class="size-5 text-gray-300 group-hover:text-violet-500 ml-auto transition-colors" />
                </button>
              </div>

              <p class="text-xs text-center text-gray-400 mt-3">
                Password for all: <code class="bg-gray-100 px-1.5 py-0.5 rounded text-gray-600 font-mono text-xs">Demo@2024Secure!</code>
              </p>
            </div>

            <script :type={Phoenix.LiveView.ColocatedHook} name=".FillCredentials">
              export default {
                mounted() {
                  this.el.querySelectorAll(".demo-cred-btn").forEach(btn => {
                    btn.addEventListener("click", () => {
                      const email = btn.dataset.email;
                      const password = btn.dataset.password;

                      const form = document.getElementById("login_form");
                      if (!form) return;

                      const emailInput = form.querySelector("input[name='user[email]']");
                      const passwordInput = form.querySelector("input[name='user[password]']");

                      if (emailInput) {
                        emailInput.value = email;
                        emailInput.dispatchEvent(new Event("input", { bubbles: true }));
                      }
                      if (passwordInput) {
                        passwordInput.value = password;
                        passwordInput.dispatchEvent(new Event("input", { bubbles: true }));
                      }

                      // Brief visual feedback
                      btn.classList.add("ring-2", "ring-violet-400");
                      setTimeout(() => btn.classList.remove("ring-2", "ring-violet-400"), 600);
                    });
                  });
                }
              }
            </script>

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
