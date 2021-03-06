defmodule Core.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Contents.Post

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :name, :string
    field :password, :string
    field :username, :string
    has_many :posts, Post, foreign_key: :author_id

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :name, :password])
    |> validate_required([:username, :name, :password])
    |> validate_length(:name, min: 2, max: 48)
    |> validate_format(:username, ~r/^[a-zA-Z0-9]*$/)
    |> validate_length(:username, min: 5, max: 16)
    |> validate_format(:password, ~r/^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])/)
    |> validate_length(:password, min: 8, max: 64)
    |> update_change(:password, &Argon2.hash_pwd_salt/1)
    |> unique_constraint(:username)
  end
end
