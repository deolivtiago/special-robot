defmodule ClarxCore.Accounts.AuthTokens do
  @moduledoc """
  Accounts.AuthTokens context
  """

  alias ClarxCore.Accounts.AuthTokens.AuthToken

  @doc """
  Creates an `AuthToken`.

  ## Examples

      iex> create_auth_token(user, token_type)
      {:ok, %AuthToken{}}

      iex> create_auth_token(bad_user, token_type)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate create_auth_token(user, token_type), to: AuthToken.Create, as: :call

  @doc """
  Verifies an `AuthToken`.

  ## Examples

      iex> verify_auth_token(token, token_type)
      {:ok, %AuthToken{}}

      iex> verify_auth_token(bad_token, token_type)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate verify_auth_token(token, token_type), to: AuthToken.Verify, as: :call

  @doc """
  Revokes an `AuthToken`.

  ## Examples

      iex> revoke_auth_token(auth_token)
      {:ok, %AuthToken{}}

      iex> revoke_auth_token(invalid_auth_token)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate revoke_auth_token(auth_token), to: AuthToken.Revoke, as: :call
end
