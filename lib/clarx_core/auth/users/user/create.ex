defmodule ClarxCore.Auth.Users.User.Create do
  alias ClarxCore.Auth.Users.User
  alias ClarxCore.Repo

  def call(attrs) do
    attrs
    |> validate()
    |> insert()
  end

  defp validate(attrs), do: User.changeset(%User{}, attrs)
  defdelegate insert(changeset), to: Repo, as: :insert
end
