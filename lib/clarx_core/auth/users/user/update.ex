defmodule ClarxCore.Auth.Users.User.Update do
  alias ClarxCore.Repo
  alias ClarxCore.Auth.Users.User

  def call(%User{} = user, attrs \\ %{}) do
    user
    |> validate(attrs)
    |> update()
  end

  defp validate(user, attrs), do: User.changeset(user, attrs)
  defdelegate update(changeset), to: Repo, as: :update
end
