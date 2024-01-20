defmodule ClarxCore.Accounts.Users.User.List do
  @moduledoc false

  alias ClarxCore.Accounts.Users.User
  alias ClarxCore.Repo

  @doc false
  def call, do: Repo.all(User)
end
