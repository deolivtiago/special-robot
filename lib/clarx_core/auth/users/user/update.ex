defmodule ClarxCore.Auth.Users.User.Update do
  @moduledoc false

  alias ClarxCore.Auth.Users.User
  alias ClarxCore.Repo
  alias Ecto.Changeset

  def call(%User{} = user, attrs \\ %{}) do
    changeset = User.changeset(user, attrs)

    if not Changeset.changed?(changeset, :password) do
      Repo.update(changeset)
    else
      %User{}
      |> Changeset.change()
      |> Changeset.add_error(:password, "must be updated by password reset")
      |> then(&{:error, &1})
    end
  end
end
