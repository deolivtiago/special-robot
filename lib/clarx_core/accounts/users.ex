defmodule ClarxCore.Accounts.Users do
  @moduledoc """
  Accounts.Users context
  """

  alias ClarxCore.Accounts.Users.User

  @doc """
  Lists all users

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  defdelegate list_users, to: User.List, as: :call

  @doc """
  Gets an user

  ## Examples

      iex> get_user(field, value)
      {:ok, %User{}}

      iex> get_user(field, bad_value)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate get_user(field, value), to: User.Get, as: :call

  @doc """
  Creates an user

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  defdelegate create_user(attrs), to: User.Create, as: :call

  @doc """
  Updates an user

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  defdelegate update_user(user, attrs), to: User.Update, as: :call

  @doc """
  Deletes an user

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate delete_user(user), to: User.Delete, as: :call

  @doc """
  Authenticates an user

  ## Examples

      iex> authenticate_user(%{field: value})
      {:ok, %User{}}

      iex> authenticate_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  defdelegate authenticate_user(attrs), to: User.Authenticate, as: :call
end
