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
  alias DogearWeb.Navigation

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
      |> assign_font_class()

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
    {:ok, bookmark} = Navigation.by_offset(socket.assigns.book, socket.assigns.bookmark, +1)

    manifets_item = Manifests.get_item_by_idref(socket.assigns.book.manifest, bookmark.idref)

    socket =
      socket
      |> assign(:bookmark, bookmark)
      |> assign(:manifets_item, manifets_item)
      |> assign_render()

    {:noreply, socket}
  end

  def handle_event("previousPlace", _params, socket) do
    {:ok, bookmark} = Navigation.by_offset(socket.assigns.book, socket.assigns.bookmark, -1)

    manifets_item = Manifests.get_item_by_idref(socket.assigns.book.manifest, bookmark.idref)

    socket =
      socket
      |> assign(:bookmark, bookmark)
      |> assign(:manifets_item, manifets_item)
      |> assign_render()

    {:noreply, socket}
  end

  def handle_event("rewindTime", _params, socket) do
    {:ok, bookmark} = Navigation.rewind(socket.assigns.book, socket.assigns.bookmark)

    manifets_item = Manifests.get_item_by_idref(socket.assigns.book.manifest, bookmark.idref)

    socket =
      socket
      |> assign(:bookmark, bookmark)
      |> assign(:manifets_item, manifets_item)
      |> assign_render()
      |> push_scroll()

    {:noreply, socket}
  end

  def handle_event("zoomIn", _params, socket) do
    text_size = Enum.min([socket.assigns.text_size + 1, 30])
    {:noreply, socket |> assign(:text_size, text_size) |> assign_font_class()}
  end

  def handle_event("zoomOut", _params, socket) do
    text_size = Enum.max([socket.assigns.text_size - 1, 04])
    {:noreply, socket |> assign(:text_size, text_size) |> assign_font_class()}
  end

  def handle_event("lineIncrease", _params, socket) do
    line_height = Enum.min([socket.assigns.line_height + 1, 30])
    {:noreply, socket |> assign(:line_height, line_height) |> assign_font_class()}
  end

  def handle_event("lineDecrease", _params, socket) do
    line_height = Enum.max([socket.assigns.line_height - 1, 10])
    {:noreply, socket |> assign(:line_height, line_height) |> assign_font_class()}
  end

  def handle_event("updateAnchor", %{"anchorId" => anchor_id}, socket) do
    {:ok, _bookmark} = Navigation.to_anchor_id(socket.assigns.bookmark, anchor_id)

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

  def topic(socket), do: "book:#{socket.assigns.book.id}"

  def assign_font_class(socket) do
    socket =
      socket
      |> assign_new(:text_size, fn -> 14 end)
      |> assign_new(:line_height, fn -> 10 end)

    text_size = socket.assigns.text_size |> Decimal.div(10) |> Decimal.round(1)

    line_height =
      socket.assigns.line_height
      |> Decimal.div(10)
      |> Decimal.round(1)

    assign(socket, :font_class, " text-[#{text_size}em] leading-[#{line_height}em] ")
  end
end
