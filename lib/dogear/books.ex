defmodule Dogear.Books do
  @moduledoc """
  The Books context.
  """

  import Ecto.Query, warn: false

  alias Dogear.Schema.Book
  alias Dogear.Metadata
  alias Dogear.Repo
  alias Dogear.Document

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
  def get_book!(id), do: Repo.get!(Book, id)

  @doc """
  Creates a book.

  ## Examples

      iex> create_book(%{field: value})
      {:ok, %Book{}}

      iex> create_book(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_book(filename) do
    with {:ok, root_file_name} <- Document.root_file_name(filename),
         {:ok, metadata} <- Metadata.read(filename) do
      attrs = %{
        filename: filename,
        root_file_name: root_file_name,
        title: Metadata.get_title(metadata),
        author: Metadata.get_author(metadata)
      }

      %Book{}
      |> Book.changeset(attrs)
      |> Repo.insert()
    else
      err -> err
    end
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

  @spec root_document_dir(Book.t()) :: String.t()
  def root_document_dir(%Book{root_file_name: root_file_name}), do: Path.dirname(root_file_name)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking book changes.

  ## Examples

      iex> change_book(book)
      %Ecto.Changeset{data: %Book{}}

  """
  def change_book(%Book{} = book, attrs \\ %{}) do
    Book.changeset(book, attrs)
  end
end
