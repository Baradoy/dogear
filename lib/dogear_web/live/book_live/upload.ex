defmodule DogearWeb.BookLive.Upload do
  @moduledoc """
  Allow uploading of anew books
  """
  use DogearWeb, :live_view

  alias Dogear.Books
  alias Dogear.Metadata

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:epub, accept: ~w(.epub), max_entries: 2)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :epub, ref)}
  end

  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :epub, fn %{path: path}, _entry ->
        with {:ok, metadata} <- Books.read_metadata(path),
             filename <- Metadata.make_filename(metadata) <> ".epub",
             dest <- Path.join([:code.priv_dir(:dogear), "static", "uploads", filename]),
             :ok <- File.cp(path, dest) do
          Books.create_book("priv/static/uploads/" <> filename, metadata)
        end
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
  end

  defp error_to_string(err), do: inspect(err)
end
