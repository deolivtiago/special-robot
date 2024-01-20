defmodule ClarxCore.Auth.Users.Actions.InsertUser do
  @moduledoc false

  alias ClarxCore.Auth.Users.User
  alias ClarxCore.Repo

  @doc false
  def call(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
