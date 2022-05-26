defmodule Dogear.Repo.Migrations.CreateBookmarks do
  use Ecto.Migration

  def change do
    create table(:bookmarks) do
      add :book_id, :integer
      add :idref, :string
      add :anchor_id, :string
      add :spine_index, :integer

      timestamps()
    end
  end
end
