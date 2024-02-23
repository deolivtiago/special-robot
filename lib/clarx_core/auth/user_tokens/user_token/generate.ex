defmodule ClarxCore.Auth.UserTokens.UserToken.Generate do
  @moduledoc false

  alias ClarxCore.Auth.JwtTokens
  alias ClarxCore.Auth.Users.User
  alias ClarxCore.Auth.UserTokens.UserToken
  alias ClarxCore.Repo

  @doc false
  def call(%User{} = user, type) when is_atom(type) do
    with {:ok, jwt_token} <- JwtTokens.generate_jwt_token(user.id, type),
         {:ok, user_token} <- insert_user_token(jwt_token) do
      user_token
      |> Repo.preload(:user)
      |> then(&{:ok, &1})
    else
      _error ->
        %UserToken{}
        |> Ecto.Changeset.change(%{user_id: user.id, type: type})
        |> Ecto.Changeset.add_error(:token, "can't be created")
        |> then(&{:error, &1})
    end
  end

  defp insert_user_token(%{token: token, claims: claims}) do
    Map.new()
    |> Map.put(:token, token)
    |> Map.put(:id, Map.fetch!(claims, :jti))
    |> Map.put(:type, Map.fetch!(claims, :typ))
    |> Map.put(:user_id, Map.fetch!(claims, :sub))
    |> Map.put(:expiration, DateTime.from_unix!(Map.fetch!(claims, :exp), :second))
    |> then(&UserToken.changeset(%UserToken{}, &1))
    |> Repo.insert()
  end
end
