defmodule DogearWeb.Plug.RenderAssets do
  @moduledoc """
  Matches the manifest href from the bookmark to the URL
  This allows links and references rom inside the book.
  """

  require Logger

  import Plug.Conn

  alias Dogear.Zip

  def init(opts \\ %{}), do: opts

  def call(conn, _opts) do
    case conn.assigns.path_manifest_item do
      %{media_type: "application/xhtml+xml"} = item ->
        Logger.info("Continuing for #{inspect(item)}")
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
    href = conn.assigns.path_manifest_item.href
    manifest = conn.assigns.book.manifest
    full_path = Path.join(manifest.root_path,href)

    with  {:ok, binary} <- Zip.file(conn.assigns.book.zip_handle, full_path) do
      opts = [
        content_type: conn.assigns.path_manifest_item.media_type,
        disposition: :inline,
        filename: href
      ]

      conn
      |> Phoenix.Controller.send_download({:binary, binary}, opts)
      |> halt()
    else
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
