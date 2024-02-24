defmodule ClarxCore.Accounts.UserTokens.UserToken.Create do
  @moduledoc false

  alias ClarxCore.Accounts.UserTokens.UserToken
  alias ClarxCore.Repo

  @doc false
  def call(attrs) when is_map(attrs) do
    changeset = UserToken.changeset(attrs)

    with {:ok, user_token} <- Repo.insert(changeset) do
      user_token
      |> Repo.preload(:user)
      |> then(&{:ok, &1})
    end
  end
end
