require "test_helper"

class CollectionsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get collections_path
    assert_response :success
    assert_select "title", "Collections | #{root_title}"
  end

  test "should get add" do
    get book_path
    assert_response :success
    assert_select "title", "Add Book | #{root_title}"
  end
end
