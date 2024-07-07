defmodule ClarxCore.Accounts.AuthTokens.AuthToken.Create do
  @moduledoc false

  alias ClarxCore.JsonWebToken
  alias ClarxCore.Accounts.AuthTokens.AuthToken
  alias ClarxCore.Accounts.Users.User
  alias ClarxCore.Repo
  alias Ecto.Changeset

  @doc false
  def call(%User{id: id}, token_type) when token_type in ~w(access refresh)a do
    changeset = changeset(id, token_type)

    with {:ok, auth_token} <- Repo.insert(changeset) do
      auth_token
      |> Repo.preload(:user)
      |> then(&{:ok, &1})
    end
  end

  defp changeset(sub, typ) do
    payload =
      Map.new()
      |> Map.put(:sub, sub)
      |> Map.put(:typ, typ)

    case JsonWebToken.from_payload(payload) do
      {:ok, jwt} ->
        AuthToken.changeset(jwt)

      {:error, _changeset} ->
        %AuthToken{}
        |> Changeset.change(%{type: typ, user_id: sub})
        |> Changeset.add_error(:token, "can't be signed")
    end
  end
end
