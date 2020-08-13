defmodule Juntos.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :username, :string, null: false
      add :name, :string
      add :email, :string, null: false
      add :avatar_url, :string

      timestamps()
    end

    create unique_index(:users, :username)
    create unique_index(:users, :email)
  end
end
