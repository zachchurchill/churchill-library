require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @expected_password = "foobar123!"
    @user = users(:librarian)
  end

  test "login with invalid information" do
    get admin_path
    assert_template "sessions/new"
    post admin_path, params: { session: { username: "", password: "" } }
    assert_template "sessions/new"
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "login with valid information" do
    get root_path
    assert_select "a[href=?]", admin_path
    get admin_path
    assert_template "sessions/new"
    post admin_path, params: { session: { username: @user.name, password: @expected_password } }
    assert flash.empty?
    assert_redirected_to root_path
    follow_redirect!
    assert_template "library/home"
    assert_select "a[href=?]", admin_path, count: 0
    assert_select "a[href=?]", logout_path
  end

  test "login with valid name/invalid password" do
    get admin_path
    post admin_path, params: { session: { username: @user.name, password: "wrong!" } }
    assert_template "sessions/new"
    assert_not flash.empty?
  end
end
