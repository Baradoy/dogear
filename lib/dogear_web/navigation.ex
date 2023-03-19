defmodule DogearWeb.Navigation do
  @moduledoc """
  Handles navigating and notifications
  """

  alias Dogear.Bookmarks
  alias Dogear.Books.Manifests
  alias Dogear.Schema

  def to_manifest_item(book, bookmark, item)
      when is_struct(book, Schema.Book) and is_struct(bookmark, Schema.Bookmark) and
             is_struct(item, Manifests.Item) do
    {:ok, bookmark} = Bookmarks.navigate_bookmark(book.spine, bookmark, item)

    Phoenix.PubSub.broadcast(Dogear.PubSub, topic(bookmark), message(bookmark))

    {:ok, bookmark}
  end

  def by_offset(book, bookmark, offset)
      when is_struct(book, Schema.Book) and is_struct(bookmark, Schema.Bookmark) and
             is_integer(offset) do
    {:ok, bookmark} = Bookmarks.navigate_bookmark(book.spine, bookmark, offset)

    Phoenix.PubSub.broadcast(Dogear.PubSub, topic(bookmark), message(bookmark))

    {:ok, bookmark}
  end

  def to_anchor_id(bookmark, anchor_id)
      when is_struct(bookmark, Schema.Bookmark) and is_binary(anchor_id) do
    {:ok, bookmark} = Bookmarks.update_bookmark(bookmark, %{anchor_id: anchor_id})

    Phoenix.PubSub.broadcast(
      Dogear.PubSub,
      topic(bookmark),
      {"updateAnchor", %{anchor_id: anchor_id}, self()}
    )

    {:ok, bookmark}
  end

  def message(bookmark), do: {"updateIdref", bookmark, self()}

  def topic(bookmark), do: "bookmark:#{bookmark.id}"
end
