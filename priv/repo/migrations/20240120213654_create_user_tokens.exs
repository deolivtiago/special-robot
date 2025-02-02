defmodule ClarxCore.Repo.Migrations.CreateUserTokens do
  use Ecto.Migration

  def change do
    create table(:user_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :token, :text, null: false
      add :expiration, :timestamptz, null: false
      add :type, :string, null: false

      add :user_id,
          references(:users, on_delete: :delete_all, on_update: :update_all, type: :binary_id),
          null: false

      timestamps(type: :timestamptz, updated_at: false)
    end

    create unique_index(:user_tokens, [:token])
    create index(:user_tokens, [:user_id])
  end
end
