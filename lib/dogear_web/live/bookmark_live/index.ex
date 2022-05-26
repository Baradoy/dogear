defmodule DogearWeb.BookmarkLive.Index do
  @moduledoc """
  Bookmarks LiveView
  """

  use DogearWeb, :live_view

  alias Dogear.Bookmarks
  alias Dogear.Schema.Bookmark

  defp assign_defaults(socket) do
    socket
    |> assign(:bookmark, nil)
  end

  @impl true
  def mount(_params, _session, socket) do
    case Bookmarks.get_latest_bookmark() do
      {:ok, bookmark} ->
        {:ok, assign(socket, :bookmark, bookmark)}

      _ ->
        socket =
          socket
          |> assign_defaults()
          |> redirect(to: Routes.book_index_path(socket, :index))

        {:ok, socket}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Bookmark")
    |> assign(:bookmark, Bookmarks.get_bookmark!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Bookmark")
    |> assign(:bookmark, %Bookmark{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Bookmarks")
    |> assign(:bookmark, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    bookmark = Bookmarks.get_bookmark!(id)
    {:ok, _} = Bookmarks.delete_bookmark(bookmark)

    {:noreply, assign(socket, :bookmarks, list_bookmarks())}
  end

  defp list_bookmarks do
    Bookmarks.list_bookmarks()
  end
end
