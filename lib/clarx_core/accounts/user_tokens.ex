defmodule ClarxCore.Accounts.UserTokens do
  @moduledoc """
  Accounts.UserTokens context
  """
  alias ClarxCore.Accounts.UserTokens.UserToken

  @doc """
  Gets an user token

  ## Examples

      iex> get_user_token(field, value)
      {:ok, %UserToken{}}

      iex> get_user_token(field, bad_value)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate get_user_token(field, value), to: UserToken.Get, as: :call

  @doc """
  Creates an user token

  ## Examples

      iex> create_user_token(%{field: value})
      {:ok, %UserToken{}}

      iex> create_user_token(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  defdelegate create_user_token(attrs), to: UserToken.Create, as: :call

  @doc """
  Deletes an user token

  ## Examples

      iex> delete_user_token(user_token)
      {:ok, %UserToken{}}

      iex> delete_user_token(invalid_user_token)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate delete_user_token(user_token), to: UserToken.Delete, as: :call
end
