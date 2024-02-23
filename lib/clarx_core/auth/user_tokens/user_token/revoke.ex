defmodule ClarxCore.Auth.UserTokens.UserToken.Revoke do
  @moduledoc false

  alias ClarxCore.Auth.UserTokens.UserToken
  alias ClarxCore.Repo

  @doc false
  def call(%UserToken{} = user_token) do
    with {:ok, user_token} <- Repo.delete(user_token) do
      user_token
      |> Repo.preload(:user)
      |> then(&{:ok, &1})
    end
  end
end
