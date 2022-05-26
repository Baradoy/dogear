defmodule Dogear.Schema.Book do
  @moduledoc """
  The basic information for an epub.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          author: String.t(),
          filename: String.t(),
          root_file_name: String.t(),
          title: String.t()
        }

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
