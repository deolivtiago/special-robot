defmodule ClarxCore.Auth.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ClarxCore.Auth.Users` context.
  """
  alias ClarxCore.Auth.Users.User
  alias ClarxCore.Repo

  @doc """
  Generate fake user attrs

    ## Examples

      iex> user_attrs(%{field: value})
      %{field: value, ...}

  """
  def user_attrs(attrs \\ %{}) do
    Map.new()
    |> Map.put(:id, Faker.UUID.v4())
    |> Map.put(:avatar_url, Faker.Internet.image_url())
    |> Map.put(:first_name, Faker.Person.first_name())
    |> Map.put(:last_name, Faker.Person.last_name())
    |> Map.put(:email, Faker.Internet.email())
    |> Map.put(:password, "PASSword@?!666")
    |> Map.put(:role, Enum.random([:user, :admin]))
    |> Map.put(:confirmed_at, DateTime.utc_now(:second))
    |> Map.put(:inserted_at, DateTime.utc_now(:second) |> DateTime.add(-366, :day))
    |> Map.put(:updated_at, DateTime.utc_now(:second))
    |> Map.merge(attrs)
  end

  @doc """
  Builds a fake user

    ## Examples

      iex> build_user(%{field: value})
      %User{field: value, ...}

  """
  def build_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(user_attrs(attrs))
    |> Ecto.Changeset.apply_action!(nil)
  end

  @doc """
  Inserts a fake user

    ## Examples

      iex> insert_user(%{field: value})
      %User{field: value, ...}

  """
  def insert_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(user_attrs(attrs))
    |> Repo.insert!()
  end
end
