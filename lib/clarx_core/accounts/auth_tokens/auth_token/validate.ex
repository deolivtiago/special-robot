defmodule ClarxCore.Accounts.AuthTokens.AuthToken.Validate do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias ClarxCore.Accounts.AuthTokens.AuthToken
  alias ClarxCore.Accounts.JsonWebTokens
  alias ClarxCore.Repo
  alias Ecto.Changeset

  @doc false
  def call(token, type) do
    with {:ok, %{token: token}} <- JsonWebTokens.validate_token(token, type) do
      query =
        from ut in AuthToken,
          where: ut.expiration > ^DateTime.utc_now(:second)

      case Repo.get_by(query, token: token) do
        %AuthToken{} = auth_token ->
          auth_token
          |> Repo.preload(:user)
          |> then(&{:ok, &1})

        _nil ->
          %AuthToken{}
          |> Changeset.change(%{token: token})
          |> Changeset.add_error(:token, "is invalid")
          |> then(&{:error, &1})
      end
    end
  end
end
