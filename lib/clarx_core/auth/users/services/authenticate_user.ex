defmodule ClarxCore.Auth.Users.Services.AuthenticateUser do
  alias ClarxCore.Auth.Users.User
  alias ClarxCore.Repo
  alias Ecto.Changeset

  def call(params) do
    with {:ok, %{email: email, password: password}} <- validate_params(params) do
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

  defp validate_params(params) do
    {%{}, %{email: :string, password: :string}}
    |> Changeset.cast(params, ~w(email password)a)
    |> Changeset.validate_required(~w(email password)a)
    |> Changeset.update_change(:email, &String.downcase/1)
    |> Changeset.validate_format(:email, ~r/^[.!?@#$%^&*_+a-z\-0-9]+[@][._+\-a-z0-9]+$/)
    |> Changeset.apply_action(:validate)
  end

  defp valid_credentials?(%User{} = user, password) do
    Argon2.verify_pass(password, user.password)
  end

  defp valid_credentials?(_nil, _password), do: Argon2.no_user_verify()
end
