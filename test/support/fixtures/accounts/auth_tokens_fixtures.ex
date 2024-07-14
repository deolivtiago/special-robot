defmodule ClarxCore.Accounts.AuthTokensFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ClarxCore.Accounts.AuthTokens` context.
  """
  import ClarxCore.JsonWebTokenFixtures

  alias ClarxCore.Accounts.AuthTokens.AuthToken
  alias ClarxCore.Accounts.Users.User
  alias ClarxCore.Repo

  @doc """
  Builds a fake auth token

    ## Examples

      iex> build_auth_token(user, opts)
      %AuthToken{field: value, ...}

  """
  def build_auth_token(%User{} = user, opts \\ []) do
    user
    |> build_jwt(opts)
    |> AuthToken.changeset()
    |> Ecto.Changeset.apply_action!(nil)
  end

  @doc """
  Inserts a fake auth token

    ## Examples

      iex> insert_auth_token(user, opts)
      %AuthToken{field: value, ...}

  """
  def insert_auth_token(%User{} = user, opts \\ []) do
    user
    |> build_jwt(opts)
    |> AuthToken.changeset()
    |> Repo.insert!()
    |> Repo.preload(:user)
  end
end
