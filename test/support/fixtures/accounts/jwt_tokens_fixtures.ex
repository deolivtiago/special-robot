defmodule ClarxCore.Accounts.JwtTokensFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ClarxCore.Accounts.JwtTokens` context.
  """
  alias ClarxCore.Accounts.JwtTokens.JwtToken
  alias Ecto.Changeset

  @doc """
  Generate fake jwt token attrs

    ## Examples

      iex> jwt_token_attrs()
      %{field: value, ...}

  """
  def jwt_token_attrs do
    typ =
      JwtToken.Claims
      |> Ecto.Enum.values(:typ)
      |> Enum.random()

    exp =
      if match?(:refresh, typ),
        do: DateTime.add(DateTime.utc_now(:second), 14, :day),
        else: DateTime.add(DateTime.utc_now(:second), 2, :day)

    claims =
      Map.new()
      |> Map.put(:jti, Faker.UUID.v4())
      |> Map.put(:sub, Faker.UUID.v4())
      |> Map.put(:typ, typ)
      |> Map.put(:exp, DateTime.to_unix(exp))
      |> Map.put(:iss, "clarx_server")
      |> Map.put(:aud, "clarx_client")
      |> Map.put(:iat, DateTime.to_unix(DateTime.utc_now(:second)))
      |> Map.put(:nbf, DateTime.to_unix(DateTime.utc_now(:second)))

    Map.new()
    |> Map.put(:token, Base.encode64(:crypto.strong_rand_bytes(64), padding: false))
    |> Map.put(:claims, claims)
  end

  @doc """
  Builds a fake jwt token

    ## Examples

      iex> build_jwt_token()
      %JwtToken{field: value, ...}

  """
  def build_jwt_token do
    jwt_token_attrs()
    |> JwtToken.changeset()
    |> Changeset.apply_action!(nil)
  end
end
