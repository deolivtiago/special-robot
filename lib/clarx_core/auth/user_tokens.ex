defmodule ClarxCore.Auth.UserTokens do
  @moduledoc """
  Auth.UserTokens context
  """
  alias ClarxCore.Auth.UserTokens.UserToken

  @doc """
  Generates an user token

  ## Examples

      iex> generate_user_token(user, :access)
      {:ok, %UserToken{}}

      iex> generate_user_token(user, :invalid)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate generate_user_token(user, type), to: UserToken.Generate, as: :call

  @doc """
  Validates an user token

  ## Examples

      iex> validate_user_token(token, :access)
      {:ok, %UserToken{}}

      iex> validate_user_token(token, :invalid)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate validate_user_token(token, type), to: UserToken.Validate, as: :call

  @doc """
  Revokes an user token

  ## Examples

      iex> revoke_user_token(user_token)
      {:ok, %UserToken{}}

      iex> revoke_user_token(invalid_user_token)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate revoke_user_token(user_token), to: UserToken.Revoke, as: :call
end
