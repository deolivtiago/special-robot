defmodule ClarxCore.Accounts.AuthTokensFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ClarxCore.Accounts.AuthTokens` context.
  """
  alias ClarxCore.Accounts.AuthTokens.AuthToken
  alias ClarxCore.Accounts.JsonWebTokens.JsonWebToken
  alias ClarxCore.Accounts.Users.User
  alias ClarxCore.Repo

  @doc """
  Builds a fake json web token

    ## Examples

      iex> build_json_web_token(user, token_type)
      %AuthToken{field: value, ...}

  """
  def build_json_web_token(sub, typ) when typ in ~w(access refresh)a do
    exp =
      if match?(:refresh, typ),
        do: DateTime.add(DateTime.utc_now(), 14, :day),
        else: DateTime.add(DateTime.utc_now(), 2, :day)

    extra_claims =
      Map.new()
      |> Map.put("sub", sub)
      |> Map.put("typ", typ)
      |> Map.put("exp", DateTime.to_unix(exp, :second))

    with {:ok, token, claims} <- JsonWebToken.Signer.generate_and_sign(extra_claims) do
      %JsonWebToken{
        token: token,
        claims:
          struct(
            %JsonWebToken.Claims{},
            Enum.map(claims, fn {k, v} -> {String.to_atom(k), v} end)
          )
      }
    end
  end

  @doc """
  Builds a fake auth token

    ## Examples

      iex> build_auth_token(user, token_type)
      %AuthToken{field: value, ...}

  """
  def build_auth_token(%User{} = user, token_type) when token_type in ~w(access refresh)a do
    user.id
    |> build_json_web_token(token_type)
    |> AuthToken.changeset()
    |> Ecto.Changeset.apply_action!(nil)
  end

  @doc """
  Inserts a fake auth token

    ## Examples

      iex> insert_auth_token(user, token_type)
      %AuthToken{field: value, ...}

  """
  def insert_auth_token(%User{} = user, token_type) when token_type in ~w(access refresh)a do
    user.id
    |> build_json_web_token(token_type)
    |> AuthToken.changeset()
    |> Repo.insert!()
    |> Repo.preload(:user)
  end
end
