defmodule DogearWeb.BookmarkLive.Index do
  @moduledoc """
  Bookmarks LiveView
  """

  use DogearWeb, :live_view

  alias Dogear.Bookmarks

  @impl true
  def mount(_params, _session, socket) do
    case Bookmarks.get_latest_bookmark() do
      {:ok, bookmark} ->
        socket =
          socket
          |> redirect(to: Routes.book_show_path(socket, :show, bookmark.book_id, []))

        {:ok, socket}

      _ ->
        socket =
          socket
          |> redirect(to: Routes.book_index_path(socket, :index))

        {:ok, socket}
    end
  end
end
