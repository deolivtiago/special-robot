defmodule ClarxCore.Auth.Users.Services.DeleteUser do
  @moduledoc false

  alias ClarxCore.Auth.Users.User
  alias ClarxCore.Repo

  @doc false
  def call(%User{} = user), do: Repo.delete(user)
end
