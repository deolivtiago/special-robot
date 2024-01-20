defmodule ClarxCore.Auth.Users.Actions.UpdateUser do
  @moduledoc false

  alias ClarxCore.Auth.Users.User
  alias ClarxCore.Repo

  def call(%User{} = user, attrs \\ %{}) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end
end
