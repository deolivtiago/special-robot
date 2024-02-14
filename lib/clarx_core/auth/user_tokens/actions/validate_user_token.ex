defmodule ClarxCore.Auth.UserTokens.Actions.ValidateUserToken do
  @moduledoc false

  import Ecto.Query

  alias ClarxCore.Auth.UserTokens.UserToken
  alias ClarxCore.Repo
  alias Ecto.Changeset

  @token_types ~w(access refresh confirm_account reset_password change_email)

  @doc false
  def call(token, type) when type in @token_types do
    with {:ok, %{"jti" => id}} <- UserToken.validate_token(token, type),
         {:ok, user_token} <- get_user_token(:id, id) do
      {:ok, user_token}
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
    |> Changeset.change([{key, value}])
    |> Changeset.add_error(key, message)
    |> then(&{:error, &1})
  end
end
