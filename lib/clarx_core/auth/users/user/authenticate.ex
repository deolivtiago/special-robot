defmodule ClarxCore.Auth.Users.User.Authenticate do
  @moduledoc false

  alias ClarxCore.Auth.Users.User
  alias ClarxCore.Repo
  alias Ecto.Changeset

  @doc false
  def call(user_credentials \\ %{}) do
    with {:ok, %{email: email, password: password}} <- User.validate_credentials(user_credentials) do
      user = Repo.get_by(User, email: email)

      if valid_credentials?(user, password) do
        {:ok, user}
      else
        %User{}
        |> Changeset.change(%{email: email, password: password})
        |> Changeset.add_error(:email, "invalid credentials")
        |> Changeset.add_error(:password, "invalid credentials")
        |> then(&{:error, &1})
      end
    end
  end

  defp valid_credentials?(%User{} = user, password) do
    Argon2.verify_pass(password, user.password)
  end

  defp valid_credentials?(_nil, _password), do: Argon2.no_user_verify()
end
