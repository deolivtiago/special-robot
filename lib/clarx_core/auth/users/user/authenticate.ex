defmodule ClarxCore.Auth.Users.User.Authenticate do
  @moduledoc false

  alias ClarxCore.Auth.Users.User
  alias ClarxCore.Repo
  alias Ecto.Changeset

  @doc false
  def call(credentials) when is_map(credentials) do
    with {:ok, %{email: email, password: password}} <- validate_credentials(credentials) do
      user = Repo.get_by(User, email: email)

      if valid_password?(user, password) do
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

  defp validate_credentials(credentials) do
    {%{}, %{email: :string, password: :string}}
    |> Changeset.cast(credentials, ~w(email password)a)
    |> Changeset.validate_required(~w(email password)a)
    |> Changeset.update_change(:email, &String.downcase/1)
    |> Changeset.validate_format(:email, ~r/^[.!?@#$%^&*_+a-z\-0-9]+[@][._+\-a-z0-9]+$/)
    |> Changeset.apply_action(:validate)
  end

  defp valid_password?(%User{} = user, password) when is_binary(password) do
    Argon2.verify_pass(password, user.password)
  end

  defp valid_password?(_nil, _password), do: Argon2.no_user_verify()
end
