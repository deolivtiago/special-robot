defmodule ClarxCore.Auth.Users.Services.InsertUser do
  alias ClarxCore.Auth.Users.User
  alias ClarxCore.Repo

  def call(params) do
    params
    |> User.changeset()
    |> Repo.insert()
  end
end
