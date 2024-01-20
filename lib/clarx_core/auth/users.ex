defmodule ClarxCore.Auth.Users do
  @moduledoc """
  Auth.Users context
  """

  alias ClarxCore.Auth.Users.Actions

  @doc """
  Lists all users

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  defdelegate list_users, to: Actions.ListUsers, as: :call

  @doc """
  Gets an user

  ## Examples

      iex> get_user(field, value)
      {:ok, %User{}}

      iex> get_user(field, bad_value)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate get_user(field, value), to: Actions.GetUser, as: :call

  @doc """
  Inserts an user

  ## Examples

      iex> insert_user(%{field: value})
      {:ok, %User{}}

      iex> insert_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  defdelegate insert_user(attrs), to: Actions.InsertUser, as: :call

  @doc """
  Updates an user

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  defdelegate update_user(user, attrs), to: Actions.UpdateUser, as: :call

  @doc """
  Deletes an user

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate delete_user(user), to: Actions.DeleteUser, as: :call

  @doc """
  Authenticates an user

  ## Examples

      iex> authenticate_user(%{field: value})
      {:ok, %User{}}

      iex> authenticate_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  defdelegate authenticate_user(credentials), to: Actions.AuthenticateUser, as: :call
end
