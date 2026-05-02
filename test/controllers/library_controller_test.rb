require "test_helper"

class LibraryControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get root_path
    assert_response :success
    assert_select "title", "Books | #{root_title}"
    assert_select "h1", "Welcome to the Library"
    assert_select "p", "The Churchill Library houses books from all our family members. Explore our books using the provided search and filters."
    assert_select "input[id='title']"
    assert_select "select[id='owner']"
    assert_select "select[id='author']"
    assert_select "select[id='genre']"
    assert_select "tr[aria-label='book row']"
    assert_select "a[href=?]", root_path, count: 1
    assert_select "a[href=?]", books_path, count: 0
    assert_select "a[href=?]", admin_path
  end
end
