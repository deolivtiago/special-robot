defmodule ClarxCore.Auth.UserTokens.UserToken do
  @moduledoc """
  User token schema
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__
  alias ClarxCore.Auth.Users.User

  @valid_uuid ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime]

  schema "user_tokens" do
    field :token, :string
    field :expiration, :utc_datetime

    field :type, Ecto.Enum,
      values: ~w(access refresh code)a,
      default: :code

    belongs_to :user, User

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(attrs) when is_map(attrs) do
    required_attrs = ~w(user_id)a
    optional_attrs = ~w(id token expiration type)a

    %UserToken{expiration: DateTime.add(DateTime.utc_now(:second), 10, :minute)}
    |> cast(attrs, required_attrs ++ optional_attrs)
    |> validate_required(required_attrs)
    |> unique_constraint(:id, name: :user_tokens_pkey)
    |> update_change(:id, &String.downcase/1)
    |> validate_format(:id, @valid_uuid)
    |> update_change(:user_id, &String.downcase/1)
    |> validate_format(:user_id, @valid_uuid)
    |> unique_constraint(:token)
    |> assoc_constraint(:user)
    |> validate_condition(:type, &auth_token_type?/1, &validate_required(&1, optional_attrs))
    |> validate_condition(:type, &code_token_type?/1, &put_change(&1, :token, generate_code()))
  end

  defp validate_condition(changeset, key, cond_func, do_func) do
    field = fetch_field!(changeset, key)

    if cond_func.(field) do
      do_func.(changeset)
    else
      changeset
    end
  end

  defp auth_token_type?(type), do: Enum.member?(~w(access refresh)a, type)
  defp code_token_type?(type), do: match?(:code, type)

  defp generate_code, do: Enum.random(000_000..999_999) |> Integer.to_string()
end
