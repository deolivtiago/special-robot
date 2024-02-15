defmodule ClarxCore.Auth.Users.User.Authenticate do
  alias ClarxCore.Auth.Users.User
  alias ClarxCore.Repo

  import Ecto.Changeset

  def call(credentials \\ %{}) do
    credentials
    |> validate()
    |> authenticate()
  end

  defp validate(credentials) do
    credentials
    |> User.credentials_changeset()
    |> apply_action(:validate)
  end

  defp authenticate({:ok, %{email: email, password: password}}) do
    user = Repo.get_by(User, email: email)

    if valid_credentials?(user, password) do
      {:ok, user}
    else
      %User{}
      |> change(%{email: email, password: password})
      |> add_error(:email, "invalid credentials")
      |> add_error(:password, "invalid credentials")
      |> then(&{:error, &1})
    end
  end

  defp authenticate(error), do: error

  defp valid_credentials?(%User{password: password_hash}, password) do
    Argon2.verify_pass(password, password_hash)
  end

  defp valid_credentials?(_nil, _password), do: Argon2.no_user_verify()
end
