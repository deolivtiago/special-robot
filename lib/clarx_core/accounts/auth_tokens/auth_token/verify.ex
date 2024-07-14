defmodule ClarxCore.Accounts.AuthTokens.AuthToken.Verify do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias ClarxCore.Accounts.AuthTokens.AuthToken
  alias ClarxCore.JsonWebToken
  alias ClarxCore.Repo
  alias Ecto.Changeset

  @doc false
  def call(token, token_type) when is_atom(token_type) do
    query =
      from ut in AuthToken,
        where: ut.expiration > ^DateTime.utc_now(:second) and ut.type == ^token_type

    with {:ok, %{claims: %{typ: ^token_type}}} <- JsonWebToken.from_token(token),
         %AuthToken{} = auth_token <- Repo.get_by(query, token: token) do
      auth_token
      |> Repo.preload(:user)
      |> then(&{:ok, &1})
    else
      _error ->
        %AuthToken{}
        |> Changeset.change(%{token: token})
        |> Changeset.add_error(:token, "is invalid")
        |> then(&{:error, &1})
    end
  end
end
