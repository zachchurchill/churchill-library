require "test_helper"

class CollectionsButtonsTest < ActionDispatch::IntegrationTest
  def setup
    @expected_password = "foobar123!"
    @user = users(:librarian)
  end

  test "only AI chat button available for users not logged in" do
    get collections_path
    assert_not logged_in?
    assert_select "button[id=?]", "ai-chat"
    assert_select "a[href=?]", book_path, count: 0
  end

  test "add book and AI chat buttons available for users logged in" do
    get admin_path
    post admin_path, params: { session: { username: @user.name, password: @expected_password } }
    assert_redirected_to collections_path
    follow_redirect!
    assert logged_in?
    assert_template "collections/show"
    assert_select "button[id=?]", "ai-chat"
    assert_select "a[href=?]", book_path
  end
end
