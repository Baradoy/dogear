defmodule Dogear.Books do
  @moduledoc """
  The Books context.
  """

  import Ecto.Query, warn: false

  require Logger

  alias Dogear.Books.Manifests
  alias Dogear.Books.Spines
  alias Dogear.Schema.Book
  alias Dogear.Metadata
  alias Dogear.Repo
  alias Dogear.Document
  alias Dogear.Zip

  @uploads_path Application.compile_env(:dogear, :uploads_path)

  @doc """
  Returns the list of books.

  ## Examples

      iex> list_books()
      [%Book{}, ...]

  """
  def list_books do
    Repo.all(Book)
  end

  @doc """
  Gets a single book.

  Raises `Ecto.NoResultsError` if the Book does not exist.

  ## Examples

      iex> get_book!(123)
      %Book{}

      iex> get_book!(456)
      ** (Ecto.NoResultsError)

  """
  def get_book!(id), do: Book |> Repo.get!(id) |> load_virtual()

  @doc """
  Creates a book.
  """
  def create_book(filename, metadata) when is_binary(filename) do
    attrs = %{
      filename: filename,
      title: Metadata.get_title(metadata),
      author: Metadata.get_author(metadata)
    }

    %Book{}
    |> Book.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a book.

  ## Examples

      iex> update_book(book, %{field: new_value})
      {:ok, %Book{}}

      iex> update_book(book, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_book(%Book{} = book, attrs) do
    book
    |> Book.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a book.

  ## Examples

      iex> delete_book(book)
      {:ok, %Book{}}

      iex> delete_book(book)
      {:error, %Ecto.Changeset{}}

  """
  def delete_book(%Book{} = book) do
    Repo.delete(book)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking book changes.

  ## Examples

      iex> change_book(book)
      %Ecto.Changeset{data: %Book{}}

  """
  def change_book(%Book{} = book, attrs \\ %{}) do
    Book.changeset(book, attrs)
  end

  def read_metadata(filename) do
    with {:ok, zip_handle} <- Zip.open(filename),
         {:ok, root_file_name} <- Document.root_filename(zip_handle),
         {:ok, root_document} <- Document.root_docuemnt(zip_handle, root_file_name) do
      Metadata.read(root_document)
    end
  end

  def load_virtual(%Book{} = book) do
    Logger.warn("Book: #{inspect(book)}")

    book
    |> load_zip_handle()
    |> load_root_filename()
    |> load_root_document()
    |> load_spine()
    |> load_manifest()
    |> clear_root_document()
  end

  defp load_zip_handle(%Book{} = book) do
    path = Path.join([@uploads_path, book.filename])
    {:ok, zip_handle} = Zip.open(path)
    %Book{book | zip_handle: zip_handle}
  end

  defp load_root_filename(%Book{} = book) do
    {:ok, root_file_name} = Document.root_filename(book.zip_handle)
    %Book{book | root_file_name: root_file_name}
  end

  defp load_root_document(%Book{} = book) do
    {:ok, root_document} = Document.root_docuemnt(book.zip_handle, book.root_file_name)
    %Book{book | root_document: root_document}
  end

  defp load_spine(%Book{} = book) do
    spine = Spines.create_spine(book.root_document)
    %Book{book | spine: spine}
  end

  defp load_manifest(%Book{} = book)
       when not is_nil(book.root_document) and not is_nil(book.root_file_name) do
    manifest = Manifests.create_manifest(book.root_document, book.root_file_name)
    %Book{book | manifest: manifest}
  end

  defp clear_root_document(%Book{} = book) do
    %Book{book | root_document: nil}
  end
end
