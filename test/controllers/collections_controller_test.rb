require "test_helper"

class CollectionsControllerTest < ActionDispatch::IntegrationTest
  test "pagination is included and defaults to 10 records" do
    get collections_path
    assert_template "collections/show"
    assert_select "div.pagination", count: 1
    assert_select "tr[aria-label='book row']", count: 10
  end
end
