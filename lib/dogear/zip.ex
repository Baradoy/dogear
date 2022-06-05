defmodule Dogear.Zip do
  @moduledoc """
  Wrapper around erlang :zip
  """

  @spec open(String.t()) :: {:ok, :zip.handle()} | {:error, any()}
  def open(archive) when is_binary(archive) do
    archive
    |> String.to_charlist()
    |> :zip.zip_open([:memory])
  end

  @spec close(:zip.handle()) :: :ok
  def close(zip_handle) do
    :zip.zip_close(zip_handle)
  end

  def list_dir(zip_handle) do
    :zip.zip_list_dir(zip_handle)
  end

  def list_files(zip_handle) do
    list_dir(zip_handle)
  end

  def file(zip_handle, filename) do
    filename
    |> String.to_charlist()
    |> :zip.zip_get(zip_handle)
    |> case do
      {:ok, {_filenname, contents}} -> {:ok, contents}
      {:error, _} = error -> error
    end
  end
end
