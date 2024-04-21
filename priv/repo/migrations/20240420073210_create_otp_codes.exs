defmodule ClarxCore.Repo.Migrations.CreateOtpCodes do
  use Ecto.Migration

  def change do
    create table(:otp_codes, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :code, :string, size: 6, null: false
      add :email, :string, null: false
      add :type, :string, null: false
      add :expiration, :timestamptz, null: false

      timestamps(type: :timestamptz, updated_at: false)
    end

    create unique_index(:otp_codes, [:code, :email])
  end
end
