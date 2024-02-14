defmodule ClarxCore.Auth.UserTokens.Actions.GenerateUserToken do
  @moduledoc false

  alias ClarxCore.Auth.Users.User
  alias ClarxCore.Auth.UserTokens.UserToken
  alias ClarxCore.Repo
  alias Ecto.Changeset

  @token_types ~w(access refresh confirm_account reset_password change_email)

  @doc false
  def call(%User{id: id}, type) when type in @token_types do
    case UserToken.generate_token(id, type) do
      {:ok, token, %{"exp" => exp, "jti" => id}} ->
        Map.new()
        |> Map.put(:id, id)
        |> Map.put(:token, token)
        |> Map.put(:expiration, DateTime.from_unix!(exp))
        |> Map.put(:type, type)
        |> Map.put(:user_id, id)
        |> insert_user_token()

      {:error, _reason} ->
        %UserToken{}
        |> Changeset.change(%{user_id: id, type: type})
        |> Changeset.add_error(:token, "signing failure")
        |> then(&{:error, &1})
    end
  end

  defp insert_user_token(attrs) do
    changeset = UserToken.changeset(%UserToken{}, attrs) |> IO.inspect()

    with {:ok, user_token} <- Repo.insert(changeset) |> IO.inspect() do
      user_token
      |> Repo.preload(:user)
      |> then(&{:ok, &1})
    end
  end
end
