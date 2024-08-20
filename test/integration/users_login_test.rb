require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest

  test "login with invalid information" do
    get admin_path
    assert_template "sessions/new"
    post admin_path, params: { session: { username: "", password: "" } }
    assert_template "sessions/new"
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end
end
