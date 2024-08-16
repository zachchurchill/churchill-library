require "test_helper"

class LibraryControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get root_path
    assert_response :success
    assert_select "title", root_title
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", admin_path
  end

  test "should get about" do
    get about_path
    assert_response :success
    assert_select "title", "About | #{root_title}"
  end
end
