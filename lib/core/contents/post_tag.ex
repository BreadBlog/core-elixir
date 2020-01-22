defmodule Core.Contents.PostTag do
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Contents.Post
  alias Core.Contents.Tag

  @primary_key false
  @foreign_key_type :binary_id
  schema "post_tags" do
    belongs_to :post
    belongs_to :tag

    timestamps()
  end

  @doc false
  def changeset(post_tag, attrs) do
    post_tag
    |> cast(attrs, [:post_id, :tag_id])
    |> validate_required([:post_id, :tag_id])
  end
end
