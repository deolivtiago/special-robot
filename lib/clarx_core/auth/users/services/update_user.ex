defmodule ClarxCore.Auth.Users.Services.UpdateUser do
  alias ClarxCore.Auth.Users.User
  alias ClarxCore.Repo
  alias Ecto.Changeset

  def call(user, params) do
    changeset = User.changeset(user, params)

    if not Changeset.changed?(changeset, :password) do
      Repo.update(changeset)
    else
      changeset
      |> Map.update(:errors, [], &Keyword.delete(&1, :password))
      |> Changeset.add_error(:password, "must be updated by reset")
      |> then(&{:error, &1})
    end
  end
end
