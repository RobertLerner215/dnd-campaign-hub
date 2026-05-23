alias App.Repo
alias App.Accounts.User

defmodule App.Seeds do
  alias App.Repo
  alias App.Accounts.User

  def seed_user(attrs) do
    user =
      Repo.get_by(User, email: attrs.email) ||
        %User{}

    user
    |> User.email_changeset(
      %{
        name: attrs.name,
        email: attrs.email,
        role: attrs.role
      },
      validate_unique: false
    )
    |> User.password_changeset(%{password: attrs.password})
    |> User.confirm_changeset()
    |> Repo.insert_or_update!()
  end
end

App.Seeds.seed_user(%{
  name: "Dungeon Master",
  email: "dm@example.com",
  password: "dungeonmaster123",
  role: "dm"
})

App.Seeds.seed_user(%{
  name: "Player One",
  email: "player@example.com",
  password: "player123",
  role: "player"
})

IO.puts("Seeded D&D demo users:")
IO.puts("DM: dm@example.com / dungeonmaster123")
IO.puts("Player: player@example.com / player123")
