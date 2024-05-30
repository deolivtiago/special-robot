defmodule ClarxCore.Accounts.AuthTokens.AuthToken.Generate do
  @moduledoc false

  alias ClarxCore.Accounts.AuthTokens.AuthToken.JwtToken
  alias ClarxCore.Accounts.AuthTokens.AuthToken
  alias ClarxCore.Repo

  def call(user, type) do
    user.id
    |> JwtToken.new!(type)
    |> Map.from_struct()
    |> Map.put(:user_id, user.id)
    |> AuthToken.changeset()
    |> Repo.insert!()
    |> Repo.preload(:user)
    |> then(&{:ok, &1})
  rescue
    _error ->
      %AuthToken{}
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.add_error(:token, "can't be generated")
      |> then(&{:error, &1})
  end
end
