defmodule Dogear.Metadata do
  @moduledoc """
  Reads Metadata from an epub
  """

  @keys [
    :identifier,
    :title,
    :language,
    :contributor,
    :coverage,
    :creator,
    :date,
    :description,
    :format,
    :publisher,
    :relation,
    :rights,
    :source,
    :subject,
    :type
  ]
  @struct Enum.map(@keys, fn key -> {key, []} end)
  defstruct @struct

  @type t :: %__MODULE__{
          identifier: [String.t()],
          title: [String.t()],
          language: [String.t()],
          contributor: [String.t()],
          coverage: [String.t()],
          creator: [String.t()],
          date: [String.t()],
          description: [String.t()],
          format: [String.t()],
          publisher: [String.t()],
          relation: [String.t()],
          rights: [String.t()],
          source: [String.t()],
          subject: [String.t()],
          type: [String.t()]
        }

  @spec read(Floki.html_tree()) :: {:ok, t()}
  def read(root_document), do: {:ok, create_struct_from_document(root_document)}

  @spec get_title(t()) :: String.t()
  def get_title(metadata), do: Enum.join(metadata.title, " - ")

  @spec get_author(t()) :: String.t()
  def get_author(metadata), do: Enum.join(metadata.creator, " - ")

  @spec make_filename(t()) :: String.t()
  def make_filename(metadata), do: get_author(metadata) <> "-" <> get_title(metadata)

  defp create_struct_from_document(document) do
    case Floki.find(document, "package metadata") do
      [{"metadata", _attrs, elements} | _] ->
        Enum.reduce(elements, %__MODULE__{}, &put_into_struct/2)

      _ ->
        {:error, "Root document is missing metadata"}
    end
  end

  defp put_into_struct({"dc:" <> key, _attrs, values}, metadata) do
    case String.to_existing_atom(key) do
      atom_key when atom_key in @keys ->
        Map.update!(metadata, atom_key, fn current -> current ++ values end)

      _ ->
        metadata
    end
  end

  defp put_into_struct({_element, _attrs, _values}, metadata), do: metadata
end
