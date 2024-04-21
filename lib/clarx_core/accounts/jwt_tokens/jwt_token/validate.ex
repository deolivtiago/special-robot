defmodule ClarxCore.Accounts.JwtTokens.JwtToken.Validate do
  @moduledoc false

  alias ClarxCore.Accounts.JwtTokens.JwtToken

  @doc false
  def call(token, typ) when is_binary(token) and is_atom(typ) do
    typ =
      JwtToken.Claims
      |> Ecto.Enum.mappings(:typ)
      |> Map.new()
      |> Map.fetch!(typ)

    case JwtToken.Signer.verify_and_validate(token) do
      {:ok, %{"typ" => ^typ} = claims} ->
        Map.new()
        |> Map.put(:token, token)
        |> Map.put(:claims, claims)
        |> JwtToken.changeset()
        |> Ecto.Changeset.apply_action(nil)

      _error ->
        %JwtToken{}
        |> Ecto.Changeset.change(%{token: token})
        |> Ecto.Changeset.add_error(:token, "is invalid")
        |> then(&{:error, &1})
    end
  end
end
