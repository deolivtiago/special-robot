defmodule ClarxCore.Accounts.Users.User.Create do
  @moduledoc false

  alias ClarxCore.Accounts.Users.User
  alias ClarxCore.Repo

  @doc false
  def call(attrs) when is_map(attrs) do
    attrs
    |> User.changeset()
    |> Repo.insert()
  end
end
