defmodule DogearWeb.BookLive.Show do
  @moduledoc """
  Read a book
  """
  use DogearWeb, :live_view

  require Logger

  alias Dogear.Bookmarks
  alias Dogear.Books
  alias Dogear.Books.Manifests
  alias Dogear.Books.Renderer
  alias Dogear.Document

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    socket =
      socket
      |> assign_new(:book, fn -> Books.get_book!(id) end)
      |> assign_new(:bookmark, fn %{book: book} ->
        Bookmarks.get_or_create_bookmark_by_book(book)
      end)
      |> assign(:manifest_item, fn %{book: book, bookmark: bookmark} ->
        Manifests.get_item_by_idref(book.manifest, bookmark.idref)
      end)

    # socket =
    #   socket
    #   |> assign(:page_title, socket.assigns.book.title)
    #   |> assign_render()
    #   |> push_scroll()
    #   |> subscribe()

    {:ok, socket}
  end

  @impl true
  def handle_params(unsigned_params, _uri, socket) do
    case unsigned_params["href"] do
      [] ->
        socket =
          socket
          |> assign(:page_title, socket.assigns.book.title)
          |> assign_render()
          |> push_scroll()
          |> subscribe()

        {:noreply, socket}

      href when is_list(href) ->
        {:noreply, push_patch(socket, to: ~p"/books/#{socket.assigns.book}/read/")}
    end
  end

  @impl true
  def handle_event("nextPlace", _params, socket) do
    {:ok, bookmark} =
      Bookmarks.navigate_bookmark(socket.assigns.book.spine, socket.assigns.bookmark, +1)

    manifets_item = Manifests.get_item_by_idref(socket.assigns.book.manifest, bookmark.idref)

    socket =
      socket
      |> assign(:bookmark, bookmark)
      |> assign(:manifets_item, manifets_item)
      |> assign_render()

    Phoenix.PubSub.broadcast(Dogear.PubSub, topic(socket), {"updateIdref", bookmark, self()})

    {:noreply, socket}
  end

  def handle_event("previousPlace", _params, socket) do
    {:ok, bookmark} =
      Bookmarks.navigate_bookmark(socket.assigns.book.spine, socket.assigns.bookmark, -1)

    manifets_item = Manifests.get_item_by_idref(socket.assigns.book.manifest, bookmark.idref)

    socket =
      socket
      |> assign(:bookmark, bookmark)
      |> assign(:manifets_item, manifets_item)
      |> assign_render()

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
    socket =
      socket
      |> assign(:bookmark, bookmark)
      |> assign_render()

    {:noreply, socket}
  end

  def handle_info({"updateIdref", _bookmark, _pid}, socket) do
    {:noreply, socket}
  end

  defp assign_render(socket) do
    %{book: book, bookmark: bookmark} = socket.assigns

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
