defmodule FlowopsWeb.UserLive.Registration do
  use FlowopsWeb, :live_view
  alias Flowops.Accounts
  alias Flowops.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="fixed inset-0 flex overflow-hidden z-50">

        <!-- LEFT SIDE: Background image with overlay -->
        <div class="hidden lg:flex w-1/2 relative">
          <img
            src="https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=1200"
            class="absolute inset-0 w-full h-full object-cover"
          />
          <div class="absolute inset-0 bg-gradient-to-br from-purple-900/80 to-indigo-900/60"></div>
          <div class="relative z-10 flex flex-col justify-end p-12 text-white">
            <h2 class="text-4xl font-extrabold mb-3">Join FlowOps today.</h2>
            <p class="text-white/70 text-lg">Manage your events and teams with real-time precision.</p>
          </div>
        </div>

        <!-- RIGHT SIDE: Register form -->
        <div class="w-full lg:w-1/2 flex items-center justify-center bg-white px-8 py-12 overflow-y-auto">
          <div class="w-full max-w-md space-y-6">

            <!-- Logo -->
            <div class="flex flex-col items-center mb-6">
              <div class="bg-gradient-to-br from-purple-700 to-indigo-600 rounded-xl p-3 mb-3">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
              </div>
              <h1 class="text-2xl font-extrabold text-gray-800">Create your account</h1>
              <p class="text-gray-500 text-sm mt-1">
                Already have an account?
                <.link navigate={~p"/users/log-in"} class="text-purple-600 font-semibold hover:underline">
                  Log in
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

            <!-- Register Form -->
            <.form
              for={@form}
              id="registration_form"
              phx-submit="save"
              phx-change="validate"
              class="space-y-4"
            >
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                <.input
                  field={@form[:email]}
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
                  autocomplete="new-password"
                  spellcheck="false"
                  required
                />
                <p class="text-xs text-gray-400 mt-1">Minimum 12 characters</p>
              </div>
              <button type="submit" phx-disable-with="Creating account..." class="btn w-full bg-gradient-to-r from-purple-700 to-indigo-600 text-white border-none hover:opacity-90 text-base rounded-xl">
                Create Account
              </button>
            </.form>

          </div>
        </div>

      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: %{user: user}}} = socket)
      when not is_nil(user) do
    {:ok, redirect(socket, to: FlowopsWeb.UserAuth.signed_in_path(socket))}
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_email(%User{}, %{}, validate_unique: false)
    {:ok, assign_form(socket, changeset), temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user_with_password(user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Account created! Please log in.")
         |> push_navigate(to: ~p"/users/log-in")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_email(%User{}, user_params, validate_unique: false)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")
    assign(socket, form: form)
  end
end
