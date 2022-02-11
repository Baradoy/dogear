defmodule Dogear.Zip do
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
end
