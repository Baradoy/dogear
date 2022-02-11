defmodule Dogear.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :filename, :string
      add :title, :string
      add :author, :string
      add :root_file_name, :string

      timestamps()
    end
  end
end
