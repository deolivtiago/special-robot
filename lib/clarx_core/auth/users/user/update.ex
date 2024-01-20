defmodule ClarxCore.Auth.Users.User.Update do
  @moduledoc false

  alias ClarxCore.Auth.Users.User
  alias ClarxCore.Repo
  alias Ecto.Changeset

  @doc false
  def call(%User{} = user, attrs) when is_map(attrs) do
    changeset = User.changeset(user, attrs)

    if Changeset.changed?(changeset, :password) do
      changeset
      |> Map.update(:errors, [], &Keyword.delete(&1, :password))
      |> Changeset.add_error(:password, "must be updated by password reset")
      |> then(&{:error, &1})
    else
      Repo.update(changeset)
    end
  end
end
