defmodule Dogear.Books.Manifests.Item do
  @moduledoc false

  defstruct [:id, :href, :media_type]

  @type t :: %{id: String.t(), href: String.t(), media_type: String.t()}

  def to_atoms({"id", id}), do: {:id, id}
  def to_atoms({"href", href}), do: {:href, href}
  def to_atoms({"media-type", media_type}), do: {:media_type, media_type}
  def to_atoms(term), do: term
end
