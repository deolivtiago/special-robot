defmodule ClarxCore.Auth.Users.User.Insert do
  @moduledoc false

  alias ClarxCore.Auth.Users.User
  alias ClarxCore.Repo

  @doc false
  def call(attrs) when is_map(attrs) do
    attrs
    |> User.changeset()
    |> Repo.insert()
  end
end
