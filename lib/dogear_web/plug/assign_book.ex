defmodule DogearWeb.Plug.AssignBook do
  @moduledoc """
  Loads the book from the id on the path and puts it into conn.assigns.

  Useful because other Plugs expect the book in assigns.
  """

  import Plug.Conn

  alias Dogear.Books
  alias Dogear.Bookmarks

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
        |> put_status(:not_found)
        |> Phoenix.Controller.put_view(json: DogearWeb.ErrorView)
        |> Phoenix.Controller.render(:"404")
        |> halt()
    end
  end
end
