defmodule FlowopsWeb.UserLive.Settings do
  use FlowopsWeb, :live_view

  on_mount {FlowopsWeb.UserAuth, :require_sudo_mode}

  alias Flowops.Accounts
  alias FlowopsWeb.DashboardNav

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="fixed inset-0 top-0 bg-gray-50 overflow-y-auto z-40">

        <DashboardNav.dashboard_nav current_scope={@current_scope} />

        <div class="max-w-2xl mx-auto p-6 mt-8">

          <!-- Header -->
          <div class="mb-8">
            <h1 class="text-3xl font-extrabold text-gray-800">Account Settings</h1>
            <p class="text-gray-500 mt-1">Manage your email and password</p>
          </div>

          <!-- Flash Messages -->
          <div :if={Phoenix.Flash.get(@flash, :info)} class="bg-blue-50 border border-blue-200 text-blue-700 rounded-xl px-4 py-3 text-sm mb-4">
            {Phoenix.Flash.get(@flash, :info)}
          </div>
          <div :if={Phoenix.Flash.get(@flash, :error)} class="bg-red-50 border border-red-200 text-red-700 rounded-xl px-4 py-3 text-sm mb-4">
            {Phoenix.Flash.get(@flash, :error)}
          </div>

          <!-- Email Card -->
          <div class="bg-white rounded-2xl shadow p-6 mb-6">
            <h2 class="text-xl font-bold text-gray-800 mb-4">Change Email</h2>
            <.form
              for={@email_form}
              id="email_form"
              phx-submit="update_email"
              phx-change="validate_email"
              class="space-y-4"
            >
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                <.input
                  field={@email_form[:email]}
                  type="email"
                  autocomplete="username"
                  spellcheck="false"
                  required
                />
              </div>
              <button
                type="submit"
                phx-disable-with="Changing..."
                class="px-6 py-2 rounded-xl bg-gradient-to-r from-purple-700 to-indigo-600 text-white text-sm font-bold hover:opacity-90 transition"
              >
                Change Email
              </button>
            </.form>
          </div>

          <!-- Password Card -->
          <div class="bg-white rounded-2xl shadow p-6">
            <h2 class="text-xl font-bold text-gray-800 mb-4">Change Password</h2>
            <.form
              for={@password_form}
              id="password_form"
              action={~p"/users/update-password"}
              method="post"
              phx-change="validate_password"
              phx-submit="update_password"
              phx-trigger-action={@trigger_submit}
              class="space-y-4"
            >
              <input
                name={@password_form[:email].name}
                type="hidden"
                id="hidden_user_email"
                value={@current_email}
              />
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">New Password</label>
                <.input
                  field={@password_form[:password]}
                  type="password"
                  autocomplete="new-password"
                  spellcheck="false"
                  required
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Confirm New Password</label>
                <.input
                  field={@password_form[:password_confirmation]}
                  type="password"
                  autocomplete="new-password"
                  spellcheck="false"
                />
              </div>
              <button
                type="submit"
                phx-disable-with="Saving..."
                class="px-6 py-2 rounded-xl bg-gradient-to-r from-purple-700 to-indigo-600 text-white text-sm font-bold hover:opacity-90 transition"
              >
                Save Password
              </button>
            </.form>
          </div>

        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_scope.user, token) do
        {:ok, _user} ->
          put_flash(socket, :info, "Email changed successfully.")
        {:error, _} ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end
    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    email_changeset = Accounts.change_user_email(user, %{}, validate_unique: false)
    password_changeset = Accounts.change_user_password(user, %{}, hash_password: false)

    socket =
      socket
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate_email", params, socket) do
    %{"user" => user_params} = params
    email_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_email(user_params, validate_unique: false)
      |> Map.put(:action, :validate)
      |> to_form()
    {:noreply, assign(socket, email_form: email_form)}
  end

  def handle_event("update_email", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    case Accounts.change_user_email(user, user_params) do
      %{valid?: true} = changeset ->
        Accounts.deliver_user_update_email_instructions(
          Ecto.Changeset.apply_action!(changeset, :insert),
          user.email,
          &url(~p"/users/settings/confirm-email/#{&1}")
        )
        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info)}

      changeset ->
        {:noreply, assign(socket, :email_form, to_form(changeset, action: :insert))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"user" => user_params} = params
    password_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_password(user_params, hash_password: false)
      |> Map.put(:action, :validate)
      |> to_form()
    {:noreply, assign(socket, password_form: password_form)}
  end

  def handle_event("update_password", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    case Accounts.change_user_password(user, user_params) do
      %{valid?: true} = changeset ->
        {:noreply, assign(socket, trigger_submit: true, password_form: to_form(changeset))}
      changeset ->
        {:noreply, assign(socket, password_form: to_form(changeset, action: :insert))}
    end
  end
end
