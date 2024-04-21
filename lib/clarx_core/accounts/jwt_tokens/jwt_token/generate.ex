defmodule ClarxCore.Accounts.JwtTokens.JwtToken.Generate do
  @moduledoc false

  alias ClarxCore.Accounts.JwtTokens.JwtToken

  @doc false
  def call(sub, typ) when is_atom(typ) do
    extra_claims = build_extra_claims(sub, typ)

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

  defp build_extra_claims(sub, :refresh) do
    Map.new()
    |> Map.put("sub", sub)
    |> Map.put("typ", "refresh")
    |> Map.put(
      "exp",
      DateTime.utc_now(:second)
      |> DateTime.add(14, :day)
      |> DateTime.to_unix()
    )
  end

  defp build_extra_claims(sub, typ) do
    Map.new()
    |> Map.put("sub", sub)
    |> Map.put("typ", Atom.to_string(typ))
  end
end
