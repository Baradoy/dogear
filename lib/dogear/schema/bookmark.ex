defmodule Dogear.Schema.Bookmark do
  @moduledoc """
  Keeps the particular place in a Book including the scroll position through the anchor_id
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Dogear.Schema

  @type t :: %__MODULE__{
          anchor_id: String.t(),
          idref: String.t(),
          spine_index: integer(),
          book: Schema.Book.t()
        }

  schema "bookmarks" do
    field :anchor_id, :string
    field :idref, :string
    field :spine_index, :integer

    belongs_to :book, Schema.Book

    timestamps()
  end

  @doc false
  def changeset(bookmark, attrs) do
    attrs = put_book_id(attrs)

    bookmark
    |> cast(attrs, [:idref, :book_id, :anchor_id, :spine_index])
    |> validate_required([:book_id, :idref, :anchor_id, :spine_index])
  end

  defp put_book_id(%{book: book} = attrs), do: Map.put(attrs, :book_id, book.id)
  defp put_book_id(attrs), do: attrs
end
