defmodule ClarxCore.Auth.UserTokens.UserToken.Get do
  @moduledoc false

  import Ecto.Query

  alias ClarxCore.Auth.UserTokens.UserToken
  alias ClarxCore.Repo
  alias Ecto.Changeset

  @doc false
  def call(:id, id) do
    query =
      from ut in UserToken,
        where: ut.expiration > ^DateTime.utc_now(:second)

    query
    |> Repo.get_by!(%{id: id})
    |> Repo.preload(:user)
    |> then(&{:ok, &1})
  rescue
    Ecto.Query.CastError ->
      handle_error(:id, id, "is invalid")

    Ecto.NoResultsError ->
      handle_error(:id, id, "not found")

    error ->
      reraise error, __STACKTRACE__
  end

  defp handle_error(key, value, message) do
    %UserToken{}
    |> Changeset.change([{key, value}])
    |> Changeset.add_error(key, message)
    |> then(&{:error, &1})
  end
end
