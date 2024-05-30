defmodule ClarxCore.Accounts.AuthTokens do
  @moduledoc """
  Accounts.AuthTokens context
  """

  alias ClarxCore.Accounts.AuthTokens.AuthToken

  @doc """
  Verifies an auth token

  ## Examples

      iex> validate_auth_token(token, token_type)
      {:ok, %AuthToken{}}

      iex> validate_auth_token(bad_token, token_type)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate validate_auth_token(token, token_type), to: AuthToken.Validate, as: :call

  @doc """
  Creates an auth token

  ## Examples

      iex> generate_auth_token(user, token_type)
      {:ok, %AuthToken{}}

      iex> generate_auth_token(user, bad_token_type)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate generate_auth_token(user, token_type), to: AuthToken.Generate, as: :call

  @doc """
  Revokes an auth token

  ## Examples

      iex> revoke_auth_token(auth_token)
      {:ok, %AuthToken{}}

      iex> revoke_auth_token(bad_auth_token)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate revoke_auth_token(auth_token), to: AuthToken.Revoke, as: :call
end
