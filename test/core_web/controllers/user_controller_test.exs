defmodule CoreWeb.UserControllerTest do
  use CoreWeb.ConnCase

  import Core.Factory
  alias Core.Accounts
  alias Core.Accounts.User

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(build(:user))
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      users = json_response(conn, 200)["data"]
      assert is_list(users)
      assert %{} = Enum.find(users, nil, fn x -> x["username"] == "frodo" end)
      assert %{} = Enum.find(users, nil, fn x -> x["username"] == "otherperson" end)
    end
  end

  # TODO: test authenticated routes require auth

  describe "create user" do
    @tag :authenticated
    test "renders user when data is valid", %{conn: conn} do
      attrs = build(:user)
      conn = post(conn, Routes.user_path(conn, :create), user: attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      res = json_response(conn, 200)["data"]

      assert res["id"] == id
      assert res["name"] == attrs["name"]
      assert res["username"] == attrs["username"]
      assert res["password"] == nil
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: build(:user, :invalid))
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    @tag :authenticated
    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      attrs = build(:user, :update)
      conn = put(conn, Routes.user_path(conn, :update, user), user: attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      res = json_response(conn, 200)["data"]

      assert res["id"] == id
      assert res["name"] == attrs["name"]
      assert res["username"] == attrs["username"]
      assert res["password"] == nil
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: build(:user, :invalid))
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

    @tag :authenticated
    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert response(conn, 204)

      conn = get(conn, Routes.user_path(conn, :show, user))
      assert json_response(conn, 404) == %{"errors" => %{"detail" => "Not Found"}}
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    %{user: user}
  end
end
