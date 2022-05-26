defmodule DogearWeb.BookLive.Show do
  @moduledoc """
  Read a book
  """
  use DogearWeb, :live_view

  alias Dogear.Bookmarks
  alias Dogear.Books
  alias Dogear.Books.Manifests
  alias Dogear.Books.Renderer
  alias Dogear.Books.Spines
  alias Dogear.Zip

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    book = Books.get_book!(id)
    root_document = Zip.root_docuemnt!(book)
    spine = Spines.create_spine(root_document)
    manifest = Manifests.create_manifest(root_document)
    bookmark = Bookmarks.get_or_create_bookmark_by_book(book, spine)

    socket =
      socket
      |> assign(:book, book)
      |> assign(:spine, spine)
      |> assign(:manifest, manifest)
      |> assign(:page_title, book.title)
      |> assign_bookmark(bookmark)
      |> push_scroll()

    {:ok, socket}
  end

  @impl true
  def handle_event("nextPlace", _params, socket) do
    {:ok, bookmark} =
      Bookmarks.navigate_bookmark(socket.assigns.spine, socket.assigns.bookmark, +1)

    socket = assign_bookmark(socket, bookmark)

    {:noreply, socket}
  end

  def handle_event("previousPlace", _params, socket) do
    {:ok, bookmark} =
      Bookmarks.navigate_bookmark(socket.assigns.spine, socket.assigns.bookmark, -1)

    socket = assign_bookmark(socket, bookmark)

    {:noreply, socket}
  end

  def handle_event("updateAnchor", %{"anchorId" => anchor_id}, socket) do
    {:ok, bookmark} = Bookmarks.update_bookmark(socket.assigns.bookmark, %{anchor_id: anchor_id})

    socket
    |> assign(:bookmark, bookmark)

    {:noreply, socket}
  end

  defp assign_bookmark(socket, bookmark) do
    href = Manifests.get_href(socket.assigns.manifest, bookmark.idref)
    href_document = Zip.href_docuemnt!(socket.assigns.book, href)
    render = Renderer.render(href_document)

    socket
    |> assign(:bookmark, bookmark)
    |> assign(:render, render)
  end

  defp push_scroll(socket) do
    if connected?(socket) do
      push_event(socket, "scrollTo", %{"anchorId" => socket.assigns.bookmark.anchor_id})
    else
      socket
    end
  end
end
