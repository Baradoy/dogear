defmodule Dogear.Zip do
  @moduledoc """
  Reads epubs and parses them into Floki documents.
  """

  def read(archive, file) when is_binary(archive) and is_binary(file) do
    archive = String.to_charlist(archive)
    file = String.to_charlist(file)

    case :zip.extract(archive, [{:file_list, [file]}, :memory]) do
      {:ok, [{_file, content}]} -> {:ok, content}
      err -> err
    end
  end

  def read!(archive, file) when is_binary(archive) and is_binary(file) do
    case read(archive, file) do
      {:ok, content} -> content
      {:error, error} -> raise error
    end
  end

  def root_docuemnt(%_{filename: filename, root_file_name: root_file_name}) do
    with {:ok, root_file} <- read(filename, root_file_name),
         {:ok, root_docuemnt} <- Floki.parse_document(root_file) do
      {:ok, root_docuemnt}
    end
  end

  def root_docuemnt!(book) do
    case root_docuemnt(book) do
      {:ok, root_docuemnt} -> root_docuemnt
      {:error, error} -> raise error
    end
  end

  def href_docuemnt(%_{filename: filename}, href) do
    with {:ok, href_file} <- read(filename, href),
         {:ok, href_docuemnt} <- Floki.parse_document(href_file) do
      {:ok, href_docuemnt}
    end
  end

  def href_docuemnt!(book, href) do
    case href_docuemnt(book, href) do
      {:ok, href_docuemnt} -> href_docuemnt
      {:error, error} -> raise error
    end
  end
end
