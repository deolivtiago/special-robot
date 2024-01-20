defmodule ClarxCore.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :first_name, :string, null: false
      add :email, :string, null: false
      add :password, :string, null: false

      add :last_name, :string, default: ""
      add :avatar_url, :string, default: ""
      add :role, :string, default: "user", null: false
      add :confirmed_at, :timestamptz

      timestamps(type: :timestamptz)
    end

    create unique_index(:users, [:email])
  end
end
