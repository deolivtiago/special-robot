defmodule ClarxCore.Accounts.JsonWebTokens.JsonWebToken.Generate do
  @moduledoc false

  alias ClarxCore.Accounts.JsonWebTokens.JsonWebToken

  @doc false
  def call(sub, typ) when is_atom(typ) do
    extra_claims = build_extra_claims!(sub, typ)

    case JsonWebToken.Signer.generate_and_sign(extra_claims) do
      {:ok, token, claims} ->
        Map.new()
        |> Map.put(:token, token)
        |> Map.put(:claims, claims)
        |> JsonWebToken.changeset()
        |> Ecto.Changeset.apply_action(nil)

      _error ->
        %JsonWebToken{}
        |> Ecto.Changeset.change(%{claims: extra_claims})
        |> Ecto.Changeset.add_error(:token, "can't be signed")
        |> then(&{:error, &1})
    end
  end

  defp build_extra_claims!(sub, typ) do
    sub = Ecto.UUID.cast!(sub)

    typ =
      JsonWebToken.Claims
      |> Ecto.Enum.mappings(:typ)
      |> Map.new()
      |> Map.fetch!(typ)

    exp =
      if match?("refresh", typ),
        do: DateTime.add(DateTime.utc_now(), 14, :day),
        else: DateTime.add(DateTime.utc_now(), 2, :day)

    Map.new()
    |> Map.put("sub", sub)
    |> Map.put("typ", typ)
    |> Map.put("exp", DateTime.to_unix(exp, :second))
  end
end
