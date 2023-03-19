defmodule DogearWeb.Plug.RenderAssets do
  @moduledoc """
  Matches the manifest href to an asset or a bookmark
  This allows links and references rom inside the book.
  """

  require Logger

  import Plug.Conn
  alias Dogear.Books.Manifests
  alias Dogear.Zip
  alias DogearWeb.Navigation

  def init(opts \\ %{}), do: opts

  def call(conn, _opts) do
    case conn.assigns.path_manifest_item do
      %{media_type: "application/xhtml+xml"} = item ->
        Logger.info("Navigating to bookmark for #{inspect(item)}")
        Navigation.to_manifest_item(conn.assigns.book, conn.assigns.bookmark, item)

        conn

      %{media_type: _media_type} = item ->
        Logger.info("Sending raw asset for #{inspect(item)}")
        conn |> raw_asset_response()

      nil ->
        Logger.warn("No item found")
        conn
    end
  end

  def raw_asset_response(conn) do
    manifest_item = conn.assigns.path_manifest_item
    href = Manifests.get_href(conn.assigns.book.manifest, manifest_item.id)

    case Zip.file(conn.assigns.book.zip_handle, href) do
      {:ok, binary} ->
        opts = [
          content_type: conn.assigns.path_manifest_item.media_type,
          disposition: :inline,
          filename: href
        ]

        conn
        |> Phoenix.Controller.send_download({:binary, binary}, opts)
        |> halt()

      error ->
        Logger.warn("assert_response failed error:#{inspect(error)}")

        conn
        |> put_status(:not_found)
        |> Phoenix.Controller.put_view(json: DogearWeb.ErrorView)
        |> Phoenix.Controller.render(:"404")
        |> halt()
    end
  end
end
