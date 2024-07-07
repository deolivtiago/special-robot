defmodule ClarxCore.Accounts.AuthTokens.AuthToken.Generate do
  @moduledoc false

  alias Ecto.Changeset
  alias ClarxCore.Accounts.AuthTokens.AuthToken
  alias ClarxCore.Accounts.Users.User
  alias ClarxCore.Accounts.JsonWebTokens
  alias ClarxCore.Repo

  @doc false

  def call(%User{id: id}, token_type) do
    with {:ok, jwt} <- JsonWebTokens.generate_token(id, token_type) do
      changeset = AuthToken.changeset(jwt)

      case Repo.insert(changeset) do
        {:ok, auth_token} ->
          auth_token
          |> Repo.preload(:user)
          |> then(&{:ok, &1})

        {:error, _changeset} ->
          %AuthToken{}
          |> Changeset.change()
          |> Changeset.add_error(:token, "can't be inserted")
          |> then(&{:error, &1})
      end
    end
  end
end
