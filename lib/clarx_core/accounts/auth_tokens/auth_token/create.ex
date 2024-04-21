defmodule ClarxCore.Accounts.AuthTokens.AuthToken.Create do
  @moduledoc false

  alias ClarxCore.Accounts.AuthTokens.AuthToken
  alias ClarxCore.Repo

  def call(user, type) do
    changeset = AuthToken.changeset(user, type)

    case Repo.insert(changeset) do
      {:ok, user_token} ->
        user_token
        |> Repo.preload(:user)
        |> then(&{:ok, &1})

      {:error, _reason} ->
        %AuthToken{}
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.add_error(:token, "can't be created")
        |> then(&{:error, &1})
    end
  end
end
