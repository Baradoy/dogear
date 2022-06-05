defmodule Dogear.Document do
  @moduledoc """
  Reads epubs and parses them into Floki documents.
  """
  alias Dogear.Books
  alias Dogear.Schema.Book

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

  def container_document(filename) do
    with {:ok, _mimetype} <- read(filename, "mimetype"),
         {:ok, container} <- read(filename, "META-INF/container.xml"),
         {:ok, container_document} <- Floki.parse_document(container) do
      {:ok, container_document}
    end
  end

  def root_file_name(filename) do
    with {:ok, container_document} <- container_document(filename),
         [root_file_name] <- Floki.attribute(container_document, "[full-path]", "full-path") do
      {:ok, root_file_name}
    end
  end

  def root_docuemnt(%Book{filename: filename, root_file_name: root_file_name}) do
    with {:ok, root_file} <- read(filename, root_file_name),
         {:ok, root_docuemnt} <- Floki.parse_document(root_file) do
      {:ok, root_docuemnt}
    end
  end

  def root_docuemnt(filename) when is_binary(filename) do
    with {:ok, root_file_name} <- root_file_name(filename),
         {:ok, root_docuemnt} <- read(filename, root_file_name) do
      {:ok, root_docuemnt}
    end
  end

  def root_docuemnt!(book) do
    case root_docuemnt(book) do
      {:ok, root_docuemnt} -> root_docuemnt
      {:error, error} -> raise error
    end
  end

  def href_docuemnt(%Book{} = book, href) do
    full_href = book |> Books.root_document_dir() |> Path.join(href) |> Path.relative_to(".")

    with {:ok, href_file} <- read(book.filename, full_href),
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
