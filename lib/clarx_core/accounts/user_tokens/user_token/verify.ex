defmodule ClarxCore.Accounts.UserTokens.UserToken.Verify do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias ClarxCore.Accounts.JwtTokens
  alias ClarxCore.Accounts.UserTokens.UserToken
  alias ClarxCore.Repo
  alias Ecto.Changeset

  @doc false
  def call(token, token_type) when token_type in ~w(access refresh)a do
    with {:ok, jwt_token} <- JwtTokens.validate_jwt_token(token, token_type),
         {:ok, user_token} <- get_user_token(:token, jwt_token.token) do
      {:ok, user_token}
    else
      _error ->
        handle_error(:token, token, "is invalid")
    end
  end

  defp get_user_token(:token, token) do
    query =
      from ut in UserToken,
        where: ut.expiration > ^DateTime.utc_now(:second)

    query
    |> Repo.get_by!(token: token)
    |> Repo.preload(:user)
    |> then(&{:ok, &1})
  rescue
    Ecto.Query.CastError ->
      handle_error(:token, token, "is invalid")

    Ecto.NoResultsError ->
      handle_error(:token, token, "not found")

    error ->
      reraise error, __STACKTRACE__
  end

  defp handle_error(key, value, message) do
    %UserToken{}
    |> Changeset.change([{key, value}])
    |> Changeset.add_error(key, message)
    |> then(&{:error, &1})
  end
end
