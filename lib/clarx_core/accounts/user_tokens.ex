defmodule ClarxCore.Accounts.UserTokens do
  @moduledoc """
  Accounts.UserTokens context
  """

  alias ClarxCore.Accounts.UserTokens.UserToken

  @doc """
  Verifies an user token

  ## Examples

      iex> verify_user_token(token, token_type)
      {:ok, %UserToken{}}

      iex> verify_user_token(bad_token, token_type)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate verify_user_token(token, token_type), to: UserToken.Verify, as: :call

  @doc """
  Creates an user token

  ## Examples

      iex> create_user_token(user, token_type)
      {:ok, %UserToken{}}

      iex> create_user_token(bad_user, token_type)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate create_user_token(user, token_type), to: UserToken.Create, as: :call

  @doc """
  Revokes an user token

  ## Examples

      iex> revoke_user_token(user_token)
      {:ok, %UserToken{}}

      iex> revoke_user_token(bad_user_token)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate revoke_user_token(user_token), to: UserToken.Revoke, as: :call
end
