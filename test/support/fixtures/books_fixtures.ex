defmodule Dogear.BooksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Dogear.Books` context.
  """

  @doc """
  Generate a book.
  """
  def book_fixture(attrs \\ %{}) do
    {:ok, book} =
      attrs
      |> Enum.into(%{
        author: "some author",
        filename: "some filename",
        root_file_name: "some root_file_name",
        title: "some title"
      })
      |> Dogear.Books.create_book()

    book
  end
end
