require "application_system_test_case"

class UsersLoginSystemTest < ApplicationSystemTestCase
  def setup
    @user = users(:librarian)
    @expected_password = "foobar123!"
  end

  test "login button redirects to home and shows welcome banner" do
    visit admin_path

    fill_in "Username", with: @user.name
    fill_in "Password", with: @expected_password
    click_button "Login"

    assert_current_path root_path, ignore_query: false
    assert_text "Welcome back, Librarian!"
    assert_link "Logout"
  end

  test "pressing enter in password field redirects to home and shows welcome banner" do
    visit admin_path

    fill_in "Username", with: @user.name
    fill_in "Password", with: @expected_password
    find("#session_password").send_keys(:enter)

    assert_current_path root_path, ignore_query: false
    assert_text "Welcome back, Librarian!"
    assert_link "Logout"
  end
end
