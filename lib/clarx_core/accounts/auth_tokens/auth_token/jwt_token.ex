defmodule ClarxCore.Accounts.AuthTokens.AuthToken.JwtToken do
  @moduledoc """
  JWT Token
  """
  use Joken.Config

  alias __MODULE__

  @two_days 60 * 60 * 24 * 2

  defstruct ~w(id token type expiration sub claims)a

  @doc """
  Builds a JWT token, raising on errors

  ## Examples

      iex> new!(sub, typ)
      %JwtToken{}

  """
  def new!(sub, typ) when is_atom(typ), do: new!(sub, Atom.to_string(typ))

  def new!(sub, typ) when is_binary(sub) and typ in ~w(access refresh) do
    case generate_and_sign(%{"sub" => sub, "typ" => typ}) do
      {:ok, token, claims} ->
        %JwtToken{
          token: token,
          claims: claims,
          id: Map.fetch!(claims, "jti"),
          sub: Map.fetch!(claims, "sub"),
          type: Map.fetch!(claims, "typ"),
          expiration: DateTime.from_unix!(Map.fetch!(claims, "exp"), :second)
        }
    end
  rescue
    _error ->
      raise "token could't be signed"
  end

  @doc """
  Verifies a JWT token, raising on errors

  ## Examples

      iex> verify!(token, typ)
      %JwtToken{}

  """
  def verify!(token, typ) when is_atom(typ), do: verify!(token, Atom.to_string(typ))

  def verify!(token, typ) when is_binary(typ) do
    case verify_and_validate(token) do
      {:ok, %{"typ" => ^typ} = claims} ->
        %JwtToken{
          token: token,
          claims: claims,
          id: Map.fetch!(claims, "jti"),
          sub: Map.fetch!(claims, "sub"),
          type: Map.fetch!(claims, "typ"),
          expiration: DateTime.from_unix!(Map.fetch!(claims, "exp"), :second)
        }
    end
  rescue
    _error -> raise "token is invalid"
  end

  add_hook(Joken.Hooks.RequiredClaims, ~w(jti typ sub exp)a)

  @impl true
  def token_config do
    default_claims(skip: [:jti], iss: "clarx_server", aud: "clarx_client", default_exp: @two_days)
    |> add_claim("jti", &generate_jti/0, &valid_jti?/1)
    |> add_claim("typ", nil, &valid_typ?/1)
    |> add_claim("sub", nil, &valid_sub?/1)
  end

  defp generate_jti, do: Ecto.UUID.generate()

  defp valid_jti?(id) do
    case Ecto.UUID.cast(id) do
      {:ok, _id} -> true
      _error -> false
    end
  end

  defp valid_typ?(typ) when typ in ~w(access refresh), do: true
  defp valid_typ?(_typ), do: false

  defp valid_sub?(sub) when is_binary(sub), do: true
  defp valid_sub?(_sub), do: false
end
