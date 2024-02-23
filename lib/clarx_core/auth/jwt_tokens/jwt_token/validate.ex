defmodule ClarxCore.Auth.JwtTokens.JwtToken.Validate do
  @moduledoc false
  alias ClarxCore.Auth.JwtTokens.JwtToken

  @doc false
  def call(token, typ) when is_binary(token) and is_atom(typ) do
    typ = Map.fetch!(JwtToken.Signer.typ_mapping(), typ)

    case JwtToken.Signer.verify_and_validate(token) do
      {:ok, %{"typ" => ^typ} = claims} ->
        %JwtToken{}
        |> JwtToken.changeset(%{token: token, claims: claims})
        |> Ecto.Changeset.apply_action!(nil)
        |> then(&{:ok, &1})

      _error ->
        %JwtToken{}
        |> Ecto.Changeset.change(%{token: token})
        |> Ecto.Changeset.add_error(:token, "is invalid")
        |> then(&{:error, &1})
    end
  end
end
