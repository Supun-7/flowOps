alias Flowops.Accounts
alias Flowops.Accounts.User
alias Flowops.Repo

# Create admin user
case Accounts.get_user_by_email("admin@flowops.com") do
  nil ->
    %User{}
    |> User.email_changeset(%{email: "admin@flowops.com"})
    |> User.password_changeset(%{password: "Admin@2024Secure!"})
    |> Repo.insert!()

    IO.puts("✅ Admin user created: admin@flowops.com")

  _user ->
    IO.puts("ℹ️  Admin user already exists, skipping.")
end
