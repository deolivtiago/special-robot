defmodule ClarxCore.Accounts.AuthTokens.AuthToken.Validate do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias ClarxCore.Accounts.AuthTokens.AuthToken.JwtToken
  alias ClarxCore.Accounts.AuthTokens.AuthToken
  alias ClarxCore.Repo
  alias Ecto.Changeset

  @doc false
  def call(token, type) do
    %JwtToken{id: id} = JwtToken.verify!(token, type)

    query =
      from ut in AuthToken,
        where: ut.expiration > ^DateTime.utc_now(:second)

    query
    |> Repo.get!(id)
    |> Repo.preload(:user)
    |> then(&{:ok, &1})
  rescue
    _error ->
      %AuthToken{}
      |> Changeset.change(%{token: token})
      |> Changeset.add_error(:token, "is invalid")
      |> then(&{:error, &1})
  end
end
