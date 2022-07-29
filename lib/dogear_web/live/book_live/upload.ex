defmodule DogearWeb.BookLive.Upload do
  @moduledoc """
  Allow uploading of anew books
  """
  use DogearWeb, :live_view

  require Logger

  alias Dogear.Books
  alias Dogear.Metadata

  @uploads_path Application.compile_env(:dogear, :uploads_path)

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
             :ok <- ensure_destination_path(),
             {:ok, filename} <- copy_file(path, metadata) do
          Books.create_book(filename, metadata)
        end
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
  end

  defp ensure_destination_path() do
    File.mkdir_p(@uploads_path)
  end

  defp copy_file(path, metadata) do
    filename = Metadata.make_filename(metadata) <> ".epub"
    dest = Path.join([@uploads_path, filename])
    Logger.warn("Copy from #{path} to #{dest}")

    case File.cp(path, dest) do
      :ok -> {:ok, filename}
      error -> error
    end
  end

  defp error_to_string(err), do: inspect(err)
end
