defmodule ClarxCore.Accounts.JwtTokens.JwtToken.Generate do
  @moduledoc false

  alias ClarxCore.Accounts.JwtTokens.JwtToken

  @doc false
  def call(sub, typ) when is_atom(typ) do
    extra_claims = build_extra_claims!(sub, typ)

    case JwtToken.Signer.generate_and_sign(extra_claims) do
      {:ok, token, claims} ->
        Map.new()
        |> Map.put(:token, token)
        |> Map.put(:claims, claims)
        |> JwtToken.changeset()
        |> Ecto.Changeset.apply_action(nil)

      _error ->
        %JwtToken{}
        |> Ecto.Changeset.change(%{claims: extra_claims})
        |> Ecto.Changeset.add_error(:token, "can't be signed")
        |> then(&{:error, &1})
    end
  end

  defp build_extra_claims!(sub, typ) do
    sub = Ecto.UUID.cast!(sub)
    typ = Map.fetch!(typ_mappings(), typ)

    Map.new()
    |> Map.put("sub", sub)
    |> Map.put("typ", typ)
  end

  defp typ_mappings, do: Ecto.Enum.mappings(JwtToken.Claims, :typ) |> Map.new()
end
