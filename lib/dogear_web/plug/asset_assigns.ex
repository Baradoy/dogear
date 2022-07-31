defmodule DogearWeb.Plug.AssetAssigns do
  @moduledoc """
  Loads the book from the id on the path and puts it into conn.assigns.

  Useful because other Plugs expect the book in assigns.
  """

  import Plug.Conn

  alias Dogear.Books
  alias Dogear.Books.Manifests.Item
  alias Dogear.Bookmarks
  alias Dogear.Books.Manifests

  alias Dogear.Schema.Bookmark
  alias Dogear.Schema.Bookmark

  def init(opts \\ %{}), do: opts

  def call(conn, _opts) do
    with %{"id" => id} <- conn.path_params,
         {:ok, book} <- Books.fetch_book(id),
         %Bookmark{} = bookmark <- Bookmarks.get_or_create_bookmark_by_book(book) do
      conn
      |> assign(:book, book)
      |> assign(:bookmark, bookmark)
    else
      {:error, %{code: :e404}} ->
        conn
        |> Phoenix.Controller.render(MyApp.Web.ErrorView, :"404")
        |> halt()
    end
  end
end
