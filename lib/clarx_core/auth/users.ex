defmodule ClarxCore.Auth.Users do
  @moduledoc """
  Auth.Users context
  """

  alias ClarxCore.Auth.Users.Services

  @doc """
  Lists all users

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  defdelegate list_users, to: Services.ListUsers, as: :call

  @doc """
  Gets an user

  ## Examples

      iex> get_user(field, value)
      {:ok, %User{}}

      iex> get_user(field, bad_value)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate get_user(field, value), to: Services.GetUser, as: :call

  @doc """
  Inserts an user

  ## Examples

      iex> insert_user(%{field: value})
      {:ok, %User{}}

      iex> insert_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  defdelegate insert_user(attrs), to: Services.InsertUser, as: :call

  @doc """
  Updates an user

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  defdelegate update_user(user, attrs), to: Services.UpdateUser, as: :call

  @doc """
  Deletes an user

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate delete_user(user), to: Services.DeleteUser, as: :call

  @doc """
  Authenticates an user

  ## Examples

      iex> authenticate_user(%{field: value})
      {:ok, %User{}}

      iex> authenticate_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  defdelegate authenticate_user(credentials), to: Services.AuthenticateUser, as: :call
end
