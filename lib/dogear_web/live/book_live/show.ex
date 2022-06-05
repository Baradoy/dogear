defmodule DogearWeb.BookLive.Show do
  @moduledoc """
  Read a book
  """
  use DogearWeb, :live_view

  alias Dogear.Bookmarks
  alias Dogear.Books
  alias Dogear.Books.Manifests
  alias Dogear.Books.Renderer
  alias Dogear.Document

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    book = Books.get_book!(id)
    bookmark = Bookmarks.get_or_create_bookmark_by_book(book)

    socket =
      socket
      |> assign(:book, book)
      |> assign(:page_title, book.title)
      |> assign_bookmark(bookmark)
      |> push_scroll()
      |> subscribe()

    {:ok, socket}
  end

  @impl true
  def handle_event("nextPlace", _params, socket) do
    {:ok, bookmark} =
      Bookmarks.navigate_bookmark(socket.assigns.book.spine, socket.assigns.bookmark, +1)

    socket = assign_bookmark(socket, bookmark)

    Phoenix.PubSub.broadcast(Dogear.PubSub, topic(socket), {"updateIdref", bookmark, self()})

    {:noreply, socket}
  end

  def handle_event("previousPlace", _params, socket) do
    {:ok, bookmark} =
      Bookmarks.navigate_bookmark(socket.assigns.book.spine, socket.assigns.bookmark, -1)

    socket = assign_bookmark(socket, bookmark)

    Phoenix.PubSub.broadcast(Dogear.PubSub, topic(socket), {"updateIdref", bookmark, self()})

    {:noreply, socket}
  end

  def handle_event("updateAnchor", %{"anchorId" => anchor_id}, socket) do
    {:ok, _bookmark} = Bookmarks.update_bookmark(socket.assigns.bookmark, %{anchor_id: anchor_id})

    Phoenix.PubSub.broadcast(
      Dogear.PubSub,
      topic(socket),
      {"updateAnchor", %{anchor_id: anchor_id}, self()}
    )

    {:noreply, socket}
  end

  @impl true
  def handle_info({"updateAnchor", %{anchor_id: anchor_id}, pid}, socket) when pid != self() do
    {:noreply, push_event(socket, "scrollTo", %{"anchorId" => anchor_id})}
  end

  def handle_info({"updateAnchor", %{anchor_id: _}, _pid}, socket) do
    {:noreply, socket}
  end

  def handle_info({"updateIdref", bookmark, pid}, socket) when pid != self() do
    socket = assign_bookmark(socket, bookmark)
    {:noreply, socket}
  end

  def handle_info({"updateIdref", _bookmark, _pid}, socket) do
    {:noreply, socket}
  end

  defp assign_bookmark(socket, bookmark) do
    book = socket.assigns.book
    href = Manifests.get_href(book.manifest, bookmark.idref)
    {:ok, href_document} = Document.href_docuemnt(book.zip_handle, href)
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

  defp subscribe(socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Dogear.PubSub, topic(socket))
    end

    socket
  end

  def topic(socket), do: "bookmark:#{socket.assigns.bookmark.id}"
end
