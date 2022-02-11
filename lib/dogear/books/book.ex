defmodule Dogear.Books.Book do
  use Ecto.Schema
  import Ecto.Changeset

  schema "books" do
    field :author, :string
    field :filename, :string
    field :root_file_name, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:filename, :title, :author, :root_file_name])
    |> validate_required([:filename, :title, :author, :root_file_name])
  end
end
