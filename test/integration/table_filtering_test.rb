require "test_helper"

class TableFilteringTest < ActionDispatch::IntegrationTest
  def setup
    @page_size = 10
  end

  test "selection of owner correctly filters table" do
    get collections_path
    assert_select "select[id='owner']"
    assert_select "select[id='owner']>option", count: 5
    assert_filter "owner", "", @page_size
    assert_filter "owner", "zach", 2
    assert_filter "owner", "courtney", 2
    assert_filter "owner", "penelope", 1
    assert_filter "owner", "system", @page_size
    assert_filter "owner", "", @page_size
  end

  test "selection of author correctly filters table" do
    get collections_path
    assert_select "select[id='author']"
    assert_select "select[id='author']>option", count: 5
    assert_filter "author", "", @page_size
    assert_filter "author", "erb", @page_size
    assert_filter "author", "rebecca yarros", 2
    assert_filter "author", "stephen king", 2
    assert_filter "author", "dr. seuss", 1
  end

  test "selection of genre correctly filters table" do
    get collections_path
    assert_select "select[id='genre']"
    assert_select "select[id='genre']>option", count: 5
    assert_filter "genre", "", @page_size
    assert_filter "genre", "horror", @page_size
    assert_filter "genre", "fantasy", 2
    assert_filter "genre", "romance", 2
    assert_filter "genre", "childrens", 1
  end

  test "search is case insensitive" do
    get collections_path
    assert_select "input[id='title']"
    assert_filter "title", "fourth", 1
    assert_filter "title", "", @page_size
    assert_filter "title", "Fourth", 1
  end

  test "search and filters work together to filter" do
    assert_filter "title", "ng", 2

    get collections_path, params: { "title": "ng", "owner": "zach" }
    assert_select "tr[aria-label='book row']"
  end

  private

  def assert_filter(param, value, count)
    get collections_path, params: { "#{param}": value }
    assert_select "tr[aria-label='book row']", count
  end
end
