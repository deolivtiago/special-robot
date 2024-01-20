defmodule ClarxCore.Accounts.Users.User.Delete do
  @moduledoc false

  alias ClarxCore.Accounts.Users.User
  alias ClarxCore.Repo

  @doc false
  def call(%User{} = user), do: Repo.delete(user)
end
