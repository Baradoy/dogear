defmodule DogearWeb.Navigation do
  @moduledoc """
  Handles navigating and notifications
  """

  alias Dogear.Bookmarks
  alias Dogear.Books.Manifests
  alias Dogear.Books.Spines
  alias Dogear.Schema

  # seconds
  @bookmark_timeout 60

  def to_manifest_item(book, bookmark, item)
      when is_struct(book, Schema.Book) and is_struct(bookmark, Schema.Bookmark) and
             is_struct(item, Manifests.Item) do
    index = Spines.get_index(book.spine, item.id)

    {:ok, bookmark} =
      update_or_create_bookmark(bookmark, %{
        anchor_id: "#",
        idref: item.id,
        spine_index: index
      })

    Phoenix.PubSub.broadcast(Dogear.PubSub, topic(bookmark), message(bookmark))

    {:ok, bookmark}
  end

  def by_offset(book, bookmark, offset)
      when is_struct(book, Schema.Book) and is_struct(bookmark, Schema.Bookmark) and
             is_integer(offset) do
    index = bookmark.spine_index + offset

    idref = Spines.get_idref(book.spine, index)

    {:ok, bookmark} =
      update_or_create_bookmark(bookmark, %{anchor_id: "#", idref: idref, spine_index: index})

    Phoenix.PubSub.broadcast(Dogear.PubSub, topic(bookmark), message(bookmark))

    {:ok, bookmark}
  end

  def to_anchor_id(bookmark, anchor_id)
      when is_struct(bookmark, Schema.Bookmark) and is_binary(anchor_id) do
    {:ok, bookmark} =
      update_or_create_bookmark(bookmark, %{
        anchor_id: anchor_id,
        idref: bookmark.idref,
        spine_index: bookmark.spine_index
      })

    Phoenix.PubSub.broadcast(
      Dogear.PubSub,
      topic(bookmark),
      {"updateAnchor", %{anchor_id: anchor_id}, self()}
    )

    {:ok, bookmark}
  end

  def rewind(book, bookmark) do
    {:ok, _bookmark} = Bookmarks.delete_bookmark(bookmark)

    bookmark = Bookmarks.get_or_create_bookmark_by_book(book)

    Phoenix.PubSub.broadcast(
      Dogear.PubSub,
      topic(bookmark),
      {"updateAnchor", %{anchor_id: bookmark.anchor_id}, self()}
    )

    {:ok, bookmark}
  end

  def update_or_create_bookmark(bookmark, attrs) do
    case get_bookmark_action(bookmark, attrs) do
      :create -> attrs |> Map.put(:book_id, bookmark.book_id) |> Bookmarks.create_bookmark()
      :update -> Bookmarks.update_bookmark(bookmark, attrs)
    end
  end

  def get_bookmark_action(
        %{anchor_id: anchor_id, idref: idref},
        %{anchor_id: anchor_id, idref: idref}
      ),
      do: :update

  def get_bookmark_action(%{idref: idref} = bookmark, %{idref: idref}) do
    bookmark_age = NaiveDateTime.diff(NaiveDateTime.utc_now(), bookmark.inserted_at, :second)

    if bookmark_age > @bookmark_timeout do
      :create
    else
      :update
    end
  end

  def get_bookmark_action(_bookmark, _attrs), do: :create

  def message(bookmark), do: {"updateIdref", bookmark, self()}

  def topic(bookmark), do: "book:#{bookmark.book_id}"
end
