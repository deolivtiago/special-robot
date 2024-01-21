defmodule ClarxCore.Auth.UserTokensFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ClarxCore.Auth.UserTokens` context.
  """
  alias ClarxCore.Auth.Users.User
  alias ClarxCore.Auth.UserTokens.UserToken
  alias ClarxCore.Repo

  @doc """
  Generate fake user token attrs

    ## Examples

      iex> user_token_attrs(user, %{field: value})
      %{field: value, ...}

  """
  def user_token_attrs(%User{} = user) do
    type = Enum.random(~w(access refresh confirm_account reset_password change_email))
    {:ok, token, %{"jti" => id, "exp" => exp}} = UserToken.generate_token(user.id, type)

    Map.new()
    |> Map.put(:id, id)
    |> Map.put(:token, token)
    |> Map.put(:expiration, DateTime.from_unix!(exp, :second))
    |> Map.put(:type, type)
    |> Map.put(:user_id, user.id)
    |> Map.put(:user, user)
    |> Map.put(:inserted_at, DateTime.utc_now(:second) |> DateTime.add(-366, :day))
  end

  @doc """
  Builds a fake user token

    ## Examples

      iex> build_user_token(user, %{field: value})
      %UserToken{field: value, ...}

  """
  def build_user_token(%User{} = user) do
    %UserToken{}
    |> UserToken.changeset(user_token_attrs(user))
    |> Ecto.Changeset.apply_action!(nil)
  end

  @doc """
  Inserts a fake user token

    ## Examples

      iex> insert_user_token(user, %{field: value})
      %UserToken{field: value, ...}

  """
  def insert_user_token(%User{} = user) do
    %UserToken{}
    |> UserToken.changeset(user_token_attrs(user))
    |> Repo.insert!()
  end
end
