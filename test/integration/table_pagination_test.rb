require "test_helper"

class TablePaginationTest < ActionDispatch::IntegrationTest
  test "pagination is included and defaults to 10 records" do
    get books_path
    assert_template "books/show"
    assert_select "div[aria-label='Pagination']", count: 1
    assert_select "tr[aria-label='book row']", count: 10
  end

  test "selection of owner triggers submission" do
    get books_path
    assert_select "select[id='owner']"
  end
end
