defmodule Dogear.Schema.Book do
  @moduledoc """
  The basic information for an epub.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Dogear.Schema.Bookmark
  alias Dogear.Books.Manifests.Manifest
  alias Dogear.Books.Spines.Spine
  alias Dogear.Metadata
  alias Dogear.Zip

  @type t :: %__MODULE__{
          author: String.t(),
          filename: String.t(),
          root_file_name: String.t(),
          title: String.t(),
          zip_handle: Zip.handle() | nil,
          root_document: Floki.html_tree() | nil,
          metadata: Metadata.t() | nil,
          spine: Spine.t() | nil,
          manifest: Manifest.t() | nil
        }

  schema "books" do
    field :author, :string
    field :filename, :string
    field :root_file_name, :string
    field :title, :string

    field :zip_handle, :any, virtual: true
    field :root_document, :any, virtual: true
    field :metadata, :any, virtual: true
    field :spine, :any, virtual: true
    field :manifest, :any, virtual: true

    has_many :bookmars, Bookmark, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:filename, :title, :author, :root_file_name])
    |> validate_required([:filename, :title, :author])
  end
end
