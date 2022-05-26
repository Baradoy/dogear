defmodule Dogear.Books.Manifests.Manifest do
  @moduledoc """
  Describes the contents of an epub.

  The bridge between ids and hrefs.
  """

  alias Dogear.Books.Manifests.Item

  defstruct [:items]

  @type t :: %__MODULE__{items: [Item.t()]}
end
