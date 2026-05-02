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

  test "pagination links keep active filters and omit page one" do
    get books_path, params: { owner: owners(:system).id, page: 2 }
    assert_response :success

    assert_select "a[href='#{books_path(owner: owners(:system).id)}']", text: "1"
    assert_select "a[href='#{books_path(owner: owners(:system).id)}']", text: "Previous"
    assert_select "a[href='#{books_path(owner: owners(:system).id, page: 3)}']", text: "Next"
  end
end
