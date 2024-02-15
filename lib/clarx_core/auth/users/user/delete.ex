defmodule ClarxCore.Auth.Users.User.Delete do
  alias ClarxCore.Auth.Users.User
  alias ClarxCore.Repo

  def call(%User{} = user), do: delete(user)
  defdelegate delete(user), to: Repo, as: :delete
end
