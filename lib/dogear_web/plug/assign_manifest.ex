defmodule DogearWeb.Plug.AssignManifest do
  @moduledoc """
  Put Manifest Items from the path and bookmark into the assigns.
  """
  import Plug.Conn

  alias Dogear.Books.Manifests

  def init(opts \\ %{}), do: opts

  def call(conn, _opts) do
    %{book: book, bookmark: bookmark} = conn.assigns
    manifest_item = Manifests.get_item_by_idref(book.manifest, bookmark.idref)
    path_manifest_item = get_path_manifest_item(conn)

    conn
    |> assign(:manifest_item, manifest_item)
    |> assign(:path_manifest_item, path_manifest_item)
  end

  defp get_path_manifest_item(%{path_params: %{"href" => [_ | _] = href_glob}} = conn) do
    manifest = conn.assigns.book.manifest
    href = Path.join(href_glob) |> Path.relative_to(manifest.root_path)

    Manifests.get_item_by_href(manifest, href)
  end

  defp get_path_manifest_item(_conn), do: nil
end
