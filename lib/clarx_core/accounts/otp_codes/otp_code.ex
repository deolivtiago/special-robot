defmodule ClarxCore.Accounts.OtpCodes.OtpCode do
  @moduledoc """
  OTP Code schema
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime]

  schema "otp_codes" do
    field :code, :string
    field :email, :string
    field :expiration, :utc_datetime

    field :type, Ecto.Enum, values: ~w(verify)a, default: :verify

    timestamps(updated_at: false)
  end

  def changeset(attrs) when is_map(attrs) do
    required_attrs = ~w(email)a

    %OtpCode{}
    |> cast(attrs, required_attrs)
    |> validate_required(required_attrs)
    |> unique_constraint(:id, name: :otp_codes_pkey)
    |> update_change(:email, &String.downcase/1)
    |> validate_length(:email, min: 3, max: 160)
    |> validate_format(:email, ~r/^[.!?@#$%^&*_+a-z\-0-9]+[@][._+\-a-z0-9]+$/)
    |> put_change(:code, Integer.to_string(Enum.random(100_000..999_999)))
    |> put_change(:expiration, DateTime.add(DateTime.utc_now(:second), 10, :minute))
    |> unique_constraint([:code, :email])
  end
end
