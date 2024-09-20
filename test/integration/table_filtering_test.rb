require "test_helper"

class TableFilteringTest < ActionDispatch::IntegrationTest
  def setup
    @page_size = 10
  end

  test "selection of owner correctly filters table" do
    get collections_path
    assert_select "select[id='owner']"
    assert_select "select[id='owner']>option", count: 5
    assert_select_option "owner", "", @page_size
    assert_select_option "owner", "zach", 2
    assert_select_option "owner", "courtney", 2
    assert_select_option "owner", "penelope", 1
    assert_select_option "owner", "system", @page_size
    assert_select_option "owner", "", @page_size
  end

  test "selection of author correctly filters table" do
    get collections_path
    assert_select "select[id='author']"
    assert_select "select[id='author']>option", count: 5
    assert_select_option "author", "", @page_size
    assert_select_option "author", "erb", @page_size
    assert_select_option "author", "rebecca yarros", 2
    assert_select_option "author", "stephen king", 2
    assert_select_option "author", "dr. seuss", 1
  end

  test "selection of genre correctly filters table" do
    get collections_path
    assert_select "select[id='genre']"
    assert_select "select[id='genre']>option", count: 5
    assert_select_option "genre", "", @page_size
    assert_select_option "genre", "horror", @page_size
    assert_select_option "genre", "fantasy", 2
    assert_select_option "genre", "romance", 2
    assert_select_option "genre", "childrens", 1
  end

  test "search is case insensitive" do
    get collections_path
    assert_select "input[id='title']"
    get collections_path, params: { "title": "fourth" }
    assert_select "tr[aria-label='book row']"

    get collections_path, params: { "title": "" }
    assert_select "tr[aria-label='book row']", @page_size

    get collections_path, params: { "title": "Fourth" }
    assert_select "tr[aria-label='book row']"
  end

  test "search and filters work together to filter" do
    get collections_path, params: { "title": "ng" }
    assert_select "tr[aria-label='book row']", count: 2

    get collections_path, params: { "title": "ng", "owner": "zach" }
    assert_select "tr[aria-label='book row']"
  end

  private

  def assert_select_option(select_id, option, count)
    get collections_path, params: { "#{select_id}": option }
    assert_select "tr[aria-label='book row']", count
  end
end
