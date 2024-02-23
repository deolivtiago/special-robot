defmodule ClarxCore.Auth.UserTokens.UserToken.Validate do
  @moduledoc false

  import Ecto.Query

  alias ClarxCore.Auth.JwtTokens
  alias ClarxCore.Auth.JwtTokens.JwtToken
  alias ClarxCore.Auth.UserTokens.UserToken
  alias ClarxCore.Repo

  @doc false
  def call(token, type) when is_binary(token) and is_atom(type) do
    with {:ok, %JwtToken{claims: %{jti: id}}} <- JwtTokens.validate_jwt_token(token, type),
         {:ok, user_token} <- get_user_token(:id, id) do
      user_token
      |> Repo.preload(:user)
      |> then(&{:ok, &1})
    else
      _error ->
        handle_error(:token, token, "is invalid")
    end
  end

  defp get_user_token(:id, id) do
    query =
      from ut in UserToken,
        where: ut.expiration > ^DateTime.utc_now(:second)

    query
    |> Repo.get_by!(%{id: id})
    |> then(&{:ok, &1})
  rescue
    Ecto.Query.CastError ->
      handle_error(:id, id, "is invalid")

    Ecto.NoResultsError ->
      handle_error(:id, id, "not found")

    error ->
      reraise error, __STACKTRACE__
  end

  defp handle_error(key, value, message) do
    %UserToken{}
    |> Ecto.Changeset.change([{key, value}])
    |> Ecto.Changeset.add_error(key, message)
    |> then(&{:error, &1})
  end
end
