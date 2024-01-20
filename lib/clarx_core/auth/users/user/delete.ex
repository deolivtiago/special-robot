defmodule ClarxCore.Auth.Users.User.Delete do
  @moduledoc false

  alias ClarxCore.Auth.Users.User
  alias ClarxCore.Repo

  @doc false
  def call(%User{} = user), do: Repo.delete(user)
end
