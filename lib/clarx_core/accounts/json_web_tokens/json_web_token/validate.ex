defmodule ClarxCore.Accounts.JsonWebTokens.JsonWebToken.Validate do
  @moduledoc false

  alias ClarxCore.Accounts.JsonWebTokens.JsonWebToken
  alias Ecto.Changeset

  @doc false
  def call(token, typ) when is_binary(token) and is_atom(typ) do
    typ =
      JsonWebToken.Claims
      |> Ecto.Enum.mappings(:typ)
      |> Map.new()
      |> Map.fetch!(typ)

    case JsonWebToken.Signer.verify_and_validate(token) do
      {:ok, %{"typ" => ^typ} = claims} ->
        Map.new()
        |> Map.put(:token, token)
        |> Map.put(:claims, claims)
        |> JsonWebToken.changeset()
        |> Changeset.apply_action!(nil)
        |> then(&{:ok, &1})

      _error ->
        %JsonWebToken{}
        |> Changeset.change(%{token: token})
        |> Changeset.add_error(:token, "is invalid")
        |> then(&{:error, &1})
    end
  end
end
