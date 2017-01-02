defmodule Rumbl.UserController do

  use Rumbl.Web, :controller

  plug :authenticate when action in [:index, :show]

  alias Rumbl.User

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> Rumbl.Auth.login(user)
        |> put_flash(:info, "#{user.name} created!")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
      {:unique, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  #  BEFORE the Plug function, we had to do this to apply the authenticate
  # function to this function. But above we use plug and it applies to any we want
  # def index(conn, _params) do
  #   case authenticate(conn) do #heavy use of case statments and pattern matching
  #     #look for halted state in connection and bubble it up
  #     %Plug.Conn{halted: true} = conn ->
  #       conn
  #     #if connection unchanged continue
  #     conn ->
  #       users = Repo.all(Rumbl.User)
  #       render conn, "index.html", users: users
  #   end
  # end
  def index(conn, _params) do
    users = Repo.all(Rumbl.User)
    render conn, "index.html", users: users
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get(Rumbl.User, id)
    render conn, "show.html", user: user
  end

  defp authenticate(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: page_path(conn, :index))
      |> halt()
    end
  end

  # This version of authenticate is not a plug.
  # defp authenticate(conn) do
  #   if conn.assigns.current_user do
  #     conn
  #   else
  #     conn
  #     |> put_flash(:error, "You must be logged in to access that page")
  #     |> redirect(to: page_path(conn, :index))
  #     |> halt()
  #   end
  # end

end
