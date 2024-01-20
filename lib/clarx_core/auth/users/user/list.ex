defmodule ClarxCore.Auth.Users.User.List do
  @moduledoc false

  alias ClarxCore.Auth.Users.User
  alias ClarxCore.Repo

  @doc false
  def call, do: Repo.all(User)
end
