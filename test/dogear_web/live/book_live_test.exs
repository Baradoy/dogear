defmodule DogearWeb.BookLiveTest do
  use DogearWeb.ConnCase

  import Phoenix.LiveViewTest
  import Dogear.BooksFixtures

  @create_attrs %{author: "some author", filename: "some filename", root_file_name: "some root_file_name", title: "some title"}
  @update_attrs %{author: "some updated author", filename: "some updated filename", root_file_name: "some updated root_file_name", title: "some updated title"}
  @invalid_attrs %{author: nil, filename: nil, root_file_name: nil, title: nil}

  defp create_book(_) do
    book = book_fixture()
    %{book: book}
  end

  describe "Index" do
    setup [:create_book]

    test "lists all books", %{conn: conn, book: book} do
      {:ok, _index_live, html} = live(conn, Routes.book_index_path(conn, :index))

      assert html =~ "Listing Books"
      assert html =~ book.author
    end

    test "saves new book", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.book_index_path(conn, :index))

      assert index_live |> element("a", "New Book") |> render_click() =~
               "New Book"

      assert_patch(index_live, Routes.book_index_path(conn, :new))

      assert index_live
             |> form("#book-form", book: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#book-form", book: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.book_index_path(conn, :index))

      assert html =~ "Book created successfully"
      assert html =~ "some author"
    end

    test "updates book in listing", %{conn: conn, book: book} do
      {:ok, index_live, _html} = live(conn, Routes.book_index_path(conn, :index))

      assert index_live |> element("#book-#{book.id} a", "Edit") |> render_click() =~
               "Edit Book"

      assert_patch(index_live, Routes.book_index_path(conn, :edit, book))

      assert index_live
             |> form("#book-form", book: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#book-form", book: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.book_index_path(conn, :index))

      assert html =~ "Book updated successfully"
      assert html =~ "some updated author"
    end

    test "deletes book in listing", %{conn: conn, book: book} do
      {:ok, index_live, _html} = live(conn, Routes.book_index_path(conn, :index))

      assert index_live |> element("#book-#{book.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#book-#{book.id}")
    end
  end

  describe "Show" do
    setup [:create_book]

    test "displays book", %{conn: conn, book: book} do
      {:ok, _show_live, html} = live(conn, Routes.book_show_path(conn, :show, book))

      assert html =~ "Show Book"
      assert html =~ book.author
    end

    test "updates book within modal", %{conn: conn, book: book} do
      {:ok, show_live, _html} = live(conn, Routes.book_show_path(conn, :show, book))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Book"

      assert_patch(show_live, Routes.book_show_path(conn, :edit, book))

      assert show_live
             |> form("#book-form", book: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#book-form", book: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.book_show_path(conn, :show, book))

      assert html =~ "Book updated successfully"
      assert html =~ "some updated author"
    end
  end
end
