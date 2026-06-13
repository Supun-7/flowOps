alias Flowops.Accounts
alias Flowops.Accounts.User
alias Flowops.Repo

# Create admin user
case Accounts.get_user_by_email("admin@flowops.com") do
  nil ->
    %User{}
    |> User.email_changeset(%{email: "admin@flowops.com"})
    |> User.password_changeset(%{password: "Admin@2024Secure!"})
    |> Ecto.Changeset.put_change(:is_admin, true)
    |> Repo.insert!()
    IO.puts("✅ Admin user created: admin@flowops.com")

  user ->
    user
    |> Ecto.Changeset.change(%{is_admin: true})
    |> Repo.update!()
    IO.puts("ℹ️  Admin user updated with is_admin: true")
end

# Create sample committee member
case Accounts.get_user_by_email("member@flowops.com") do
  nil ->
    %User{}
    |> User.email_changeset(%{email: "member@flowops.com"})
    |> User.password_changeset(%{password: "Member@2024Secure!"})
    |> Repo.insert!()
    IO.puts("✅ Member user created: member@flowops.com")

  _user ->
    IO.puts("ℹ️  Member user already exists, skipping.")
end
