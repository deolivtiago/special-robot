defmodule ClarxCore.Auth.Users.User.List do
  alias ClarxCore.Auth.Users.User
  alias ClarxCore.Repo

  def call, do: Repo.all(User)
end
