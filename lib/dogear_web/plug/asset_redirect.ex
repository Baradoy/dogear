defmodule DogearWeb.Plug.AssetRedirect do
  @moduledoc """
  Matches the manifest href from the bookmark to the URL
  This allows links and references rom inside the book.
  """

  require Logger

  import Plug.Conn

  alias Dogear.Zip

  alias DogearWeb.Router.Helpers, as: Routes

  def init(opts \\ %{}), do: opts

  def call(conn, _opts) do
    case conn.assigns.path_manifest_item do
      %{media_type: "application/xhtml+xml"} = item ->
        Logger.info("Matching path for #{inspect(item)}")
        conn |> match_path()

      %{media_type: _media_type} = item ->
        Logger.info("Sending raw asset for #{inspect(item)}")
        conn |> raw_asset_response()

      nil ->
        conn |> redirect_to_manifest_item_href()
    end
  end

  def match_path(conn) do
    %{id: manifest_item_id, href: manifest_item_href} = conn.assigns.manifest_item

    case conn.assigns.path_manifest_item do
      %{id: ^manifest_item_id} ->
        conn

      %{id: _idref} ->
        conn |> redirect_to_manifest_item_href()
    end
  end

  def raw_asset_response(conn) do
    with %{"href" => [_ | _] = href_glob} <- conn.path_params,
         path <- Path.join(href_glob) |> Path.relative_to("."),
         {:ok, binary} = Zip.file(conn.assigns.book.zip_handle, path) do
      opts = [
        content_type: conn.assigns.path_manifest_item.media_type,
        disposition: :inline,
        filename: path
      ]

      conn
      |> Phoenix.Controller.send_download({:binary, binary}, opts)
      |> halt()
    else
      error ->
        Logger.warn("assert_response failed error:#{inspect(error)}")

        conn
        |> Phoenix.Controller.render(MyApp.Web.ErrorView, :"404")
        |> halt()
    end
  end

  defp manifest_path_glob(manifest, href) do
    Path.join(manifest.root_path, href) |> Path.relative_to(".") |> String.split("/")
  end

  def redirect_to_manifest_item_href(conn) do
    path_for_glob =
      manifest_path_glob(conn.assigns.book.manifest, conn.assigns.manifest_item.href)

    Phoenix.Controller.redirect(conn,
      to: Routes.book_show_path(conn, :show, conn.assigns.book, path_for_glob)
    )
  end
end
