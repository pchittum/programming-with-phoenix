defmodule Rumbl.User do
  use Rumbl.Web, :model

  schema "users" do
    field :name, :string
    field :username, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    has_many :videos, Rumbl.Video

    timestamps
  end

# cast/4 first of all is deprecated! that's fun.
# but the way it should work is take the model %User{} as the data struct
# then take the unvalidated params, followed by a string list of required
# fields...then returns the changeset we can then follow through the pipeline
# with this changeset and apply other validations...custom validations even

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(name username), [])
    #|> IO.inspect
    |> validate_length(:username, min: 1, max: 20)
    #|> IO.inspect
  end

  def registration_changeset(model, params) do
    model
    |> changeset(params)
    |> cast(params, ~w(password), [])
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
end
