defmodule Dogear.Bookmarks do
  @moduledoc """
  The Bookmarks context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Query
  alias Dogear.Repo

  alias Dogear.Books.Spines
  alias Dogear.Books.Spines.Spine
  alias Dogear.Schema.Book
  alias Dogear.Schema.Bookmark

  def get_latest_bookmark() do
    case list_bookmarks(order_by: [desc: :updated_at]) do
      [head | _] -> {:ok, head}
      [] -> {:error, "No bookmark"}
    end
  end

  @spec get_or_create_bookmark_by_book(Book.t()) :: Bookmark.t()
  def get_or_create_bookmark_by_book(%Book{} = book) do
    case Repo.get_by(Bookmark, book_id: book.id) do
      bookmark when not is_nil(bookmark) ->
        bookmark

      nil ->
        idref = Spines.get_idref(book.spine, 0)

        {:ok, bookmark} =
          create_bookmark(%{book: book, anchor_id: "#", idref: idref, spine_index: 0})

        bookmark
    end
  end

  def navigate_bookmark(%Spine{} = spine, %Bookmark{} = bookmark, offset) do
    index = bookmark.spine_index + offset

    idref = Spines.get_idref(spine, index)

    update_bookmark(bookmark, %{anchor_id: "#", idref: idref, spine_index: index})
  end

  @doc """
  Returns the list of bookmarks.

  ## Examples

      iex> list_bookmarks()
      [%Bookmark{}, ...]

  """
  def list_bookmarks(query_opts \\ []) do
    Bookmark
    |> compose_query(query_opts)
    |> Repo.all()
  end

  def compose_query(queryable, query_opts) do
    Enum.reduce(query_opts, queryable, fn query_opt, acc -> query(acc, query_opt) end)
  end

  def query(queryable, {:order_by, order_by}), do:
    Query.order_by(queryable, ^order_by)

  @doc """
  Gets a single bookmark.

  Raises `Ecto.NoResultsError` if the Bookmark does not exist.

  ## Examples

      iex> get_bookmark!(123)
      %Bookmark{}

      iex> get_bookmark!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bookmark!(id), do: Repo.get!(Bookmark, id)

  @doc """
  Creates a bookmark.

  ## Examples

      iex> create_bookmark(%{field: value})
      {:ok, %Bookmark{}}

      iex> create_bookmark(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bookmark(attrs \\ %{}) do
    %Bookmark{}
    |> Bookmark.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bookmark.

  ## Examples

      iex> update_bookmark(bookmark, %{field: new_value})
      {:ok, %Bookmark{}}

      iex> update_bookmark(bookmark, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bookmark(%Bookmark{} = bookmark, attrs) do
    bookmark
    |> Bookmark.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a bookmark.

  ## Examples

      iex> delete_bookmark(bookmark)
      {:ok, %Bookmark{}}

      iex> delete_bookmark(bookmark)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bookmark(%Bookmark{} = bookmark) do
    Repo.delete(bookmark)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bookmark changes.

  ## Examples

      iex> change_bookmark(bookmark)
      %Ecto.Changeset{data: %Bookmark{}}

  """
  def change_bookmark(%Bookmark{} = bookmark, attrs \\ %{}) do
    Bookmark.changeset(bookmark, attrs)
  end
end
