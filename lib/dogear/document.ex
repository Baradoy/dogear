defmodule Dogear.Document do
  @moduledoc """
  Reads epubs and parses them into Floki documents.
  """
  alias Dogear.Zip

  def container_document(zip_handle) do
    with {:ok, _mimetype} <- Zip.file(zip_handle, "mimetype"),
         {:ok, container} <- Zip.file(zip_handle, "META-INF/container.xml"),
         {:ok, container_document} <- Floki.parse_document(container) do
      {:ok, container_document}
    end
  end

  @spec root_filename(Zip.handle()) :: {:ok, String.t()} | {:error, any()}
  def root_filename(zip_handle) do
    with {:ok, container_document} <- container_document(zip_handle),
         [root_file_name] <- Floki.attribute(container_document, "[full-path]", "full-path") do
      {:ok, root_file_name}
    end
  end

  def root_docuemnt(zip_handle, root_filename) do
    with {:ok, root_file} <- Zip.file(zip_handle, root_filename),
         {:ok, root_docuemnt} <- Floki.parse_document(root_file) do
      {:ok, root_docuemnt}
    end
  end

  def href_docuemnt(zip_handle, href) do
    with {:ok, href_file} <- Zip.file(zip_handle, href),
         {:ok, href_docuemnt} <- Floki.parse_document(href_file) do
      {:ok, href_docuemnt}
    end
  end
end
