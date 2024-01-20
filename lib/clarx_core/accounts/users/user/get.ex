defmodule ClarxCore.Accounts.Users.User.Get do
  @moduledoc false

  alias ClarxCore.Accounts.Users.User
  alias ClarxCore.Repo
  alias Ecto.Changeset

  @doc false
  def call(:id, id), do: get_by(:id, id)
  def call(:email, email), do: get_by(:email, email)

  defp get_by(key, value) do
    User
    |> Repo.get_by!([{key, value}])
    |> then(&{:ok, &1})
  rescue
    Ecto.Query.CastError ->
      handle_error(key, value, "is invalid")

    Ecto.NoResultsError ->
      handle_error(key, value, "not found")

    error ->
      reraise error, __STACKTRACE__
  end

  defp handle_error(key, value, message) do
    %User{}
    |> Changeset.change([{key, value}])
    |> Changeset.add_error(key, message)
    |> then(&{:error, &1})
  end
end
