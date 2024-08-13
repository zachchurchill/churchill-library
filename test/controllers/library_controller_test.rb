require "test_helper"

class LibraryControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get root_path
    assert_response :success
    assert_select "title", "Churchill Library"
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", about_path
  end

  test "should get about" do
    get about_path
    assert_response :success
    assert_select "title", "About | Churchill Library"
  end
end
