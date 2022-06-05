defmodule Dogear.Zip do
  @moduledoc """
  Wrapper around erlang :zip
  """

  @type handle() :: :zip.handle()

  @spec open(String.t()) :: {:ok, handle()} | {:error, any()}
  def open(archive) when is_binary(archive) do
    archive
    |> String.to_charlist()
    |> :zip.zip_open([:memory])
  end

  @spec close(handle()) :: :ok
  def close(zip_handle) do
    :zip.zip_close(zip_handle)
  end

  def list_dir(zip_handle) do
    :zip.zip_list_dir(zip_handle)
  end

  def list_files(zip_handle) do
    list_dir(zip_handle)
  end

  @spec file(handle(), String.t()) :: {:ok, String.t()} | {:error, any()}
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
