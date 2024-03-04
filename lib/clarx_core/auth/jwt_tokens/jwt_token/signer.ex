defmodule ClarxCore.Auth.JwtTokens.JwtToken.Signer do
  @moduledoc """
  JWT token signer
  """
  use Joken.Config

  alias ClarxCore.Auth.JwtTokens.JwtToken

  @two_days 60 * 60 * 24 * 2

  add_hook(Joken.Hooks.RequiredClaims, ~w(jti typ sub exp)a)

  @impl true
  def token_config do
    default_claims(skip: [:jti], iss: "clarx_server", aud: "clarx_client", default_exp: @two_days)
    |> add_claim("jti", &generate_uuid/0, &valid_uuid?/1)
    |> add_claim("typ", nil, &valid_typ?/1)
    |> add_claim("sub", nil, &valid_uuid?/1)
  end

  defp generate_uuid, do: Ecto.UUID.generate()

  defp valid_uuid?(id) when is_binary(id),
    do: String.match?(id, ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/)

  defp valid_uuid?(_id), do: false

  defp valid_typ?(typ) when is_binary(typ), do: Enum.member?(Map.values(typ_mapping()), typ)
  defp valid_typ?(_typ), do: false

  @doc """
  Returns all mapped typ for JWT tokens

  ## Examples

      iex> typ_mapping()
      %{access: "access", refresh: "refresh", confirm_account: ...}

  """
  def typ_mapping, do: Ecto.Enum.mappings(JwtToken.Claims, :typ) |> Map.new()
end
