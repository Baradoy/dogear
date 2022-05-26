defmodule Dogear.BookmarksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Dogear.Bookmarks` context.
  """

  @doc """
  Generate a bookmark.
  """
  def bookmark_fixture(attrs \\ %{}) do
    {:ok, bookmark} =
      attrs
      |> Enum.into(%{
        anchor_id: "some anchor_id",
        book_id: 42,
        idref: "some idref",
        spine_index: 0
      })
      |> Dogear.Bookmarks.create_bookmark()

    bookmark
  end
end
