defmodule ClarxCore.Auth.UserTokens do
  @moduledoc """
  Auth.UserTokens context
  """
  alias ClarxCore.Auth.UserTokens.UserToken

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
  Inserts an user token

  ## Examples

      iex> insert_user_token(%{field: value})
      {:ok, %UserToken{}}

      iex> insert_user_token(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  defdelegate insert_user_token(attrs), to: UserToken.Insert, as: :call

  @doc """
  deletes an user token

  ## Examples

      iex> delete_user_token(user_token)
      {:ok, %UserToken{}}

      iex> delete_user_token(invalid_user_token)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate delete_user_token(user_token), to: UserToken.Delete, as: :call
end
