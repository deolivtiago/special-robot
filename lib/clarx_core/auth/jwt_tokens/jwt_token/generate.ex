defmodule ClarxCore.Auth.JwtTokens.JwtToken.Generate do
  @moduledoc false
  alias ClarxCore.Auth.JwtTokens.JwtToken

  @doc false
  def call(sub, typ) when is_atom(typ) do
    extra_claims = build_extra_claims!(sub, typ)

    case JwtToken.Signer.generate_and_sign(extra_claims) do
      {:ok, token, claims} ->
        %JwtToken{}
        |> JwtToken.changeset(%{token: token, claims: claims})
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
    typ = Map.fetch!(JwtToken.Signer.typ_mapping(), typ)

    Map.new()
    |> Map.put("sub", sub)
    |> Map.put("typ", typ)
  end
end
