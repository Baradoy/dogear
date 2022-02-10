defmodule Dogear.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :filename, :string
      add :title, :string
      add :author, :string
      add :root_file_name, :string

      timestamps()
    end
  end
end
