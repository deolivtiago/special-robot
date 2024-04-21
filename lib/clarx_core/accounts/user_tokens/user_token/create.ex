defmodule ClarxCore.Accounts.UserTokens.UserToken.Create do
  @moduledoc false

  alias ClarxCore.Accounts.JwtTokens
  alias ClarxCore.Accounts.Users.User
  alias ClarxCore.Accounts.UserTokens.UserToken
  alias ClarxCore.Repo

  @doc false
  def call(%User{} = user, type) when type in ~w(access refresh)a do
    case JwtTokens.generate_jwt_token(user.id, type) do
      {:ok, jwt_token} ->
        jwt_token
        |> UserToken.changeset()
        |> insert_user_token()

      _error ->
        %UserToken{}
        |> Ecto.Changeset.change(%{user_id: user.id, type: type})
        |> Ecto.Changeset.add_error(:token, "can't be created")
        |> then(&{:error, &1})
    end
  end

  defp insert_user_token(changeset) do
    with {:ok, user_token} <- Repo.insert(changeset) do
      user_token
      |> Repo.preload(:user)
      |> then(&{:ok, &1})
    end
  end
end
