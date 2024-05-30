defmodule ClarxCore.Accounts.AuthTokensFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ClarxCore.Accounts.AuthTokens` context.
  """
  alias ClarxCore.Accounts.Users.User
  alias ClarxCore.Accounts.AuthTokens.AuthToken
  alias ClarxCore.Repo
  alias Ecto.Changeset

  @doc """
  Generate fake user token attrs

    ## Examples

      iex> user_token_attrs(user, %{field: value})
      %{field: value, ...}

  """
  def user_token_attrs(%User{} = user) do
    type =
      AuthToken
      |> Ecto.Enum.values(:type)
      |> Enum.random()

    Map.new()
    |> Map.put(:id, Faker.UUID.v4())
    |> Map.put(:token, Base.encode64(:crypto.strong_rand_bytes(64), padding: false))
    |> Map.put(:type, type)
    |> Map.put(:user, user)
    |> Map.put(:user_id, user.id)
    |> Map.put(:expiration, DateTime.add(DateTime.utc_now(:second), Enum.random([2, 14]), :day))
    |> Map.put(:inserted_at, DateTime.add(DateTime.utc_now(:second), Enum.random(-90..-1), :day))
  end

  @doc """
  Builds a fake user token

    ## Examples

      iex> build_auth_token(user, %{field: value})
      %AuthToken{field: value, ...}

  """
  def build_auth_token(%User{} = user) do
    user
    |> user_token_attrs()
    |> AuthToken.changeset()
    |> Changeset.apply_action!(nil)
  end

  @doc """
  Inserts a fake user token

    ## Examples

      iex> insert_auth_token(user, %{field: value})
      %AuthToken{field: value, ...}

  """
  def insert_auth_token(%User{} = user) do
    user
    |> user_token_attrs()
    |> AuthToken.changeset()
    |> Repo.insert!()
    |> Repo.preload(:user)
  end
end
