require "test_helper"

class TableFilteringTest < ActionDispatch::IntegrationTest
  def setup
    @page_size = 10
  end

  test "selection of owner correctly filters table" do
    get books_path
    assert_select "select[id='owner']"
    assert_select "select[id='owner']>option", count: 5
    assert_filter "owner", "", @page_size
    assert_filter "owner", owners(:zach).id, 2
    assert_filter "owner", owners(:courtney).id, 2
    assert_filter "owner", owners(:penelope).id, 1
    assert_filter "owner", owners(:system).id, @page_size
  end

  test "selection of author correctly filters table" do
    get books_path
    assert_select "select[id='author']"
    assert_select "select[id='author']>option", count: 5
    assert_filter "author", "", @page_size
    assert_filter "author", authors(:erb).id, @page_size
    assert_filter "author", authors(:rebecca_yarros).id, 2
    assert_filter "author", authors(:stephen_king).id, 2
    assert_filter "author", authors(:dr_seuss).id, 1
  end

  test "selection of genre correctly filters table" do
    get books_path
    assert_select "select[id='genre']"
    assert_select "select[id='genre']>option", count: 5
    assert_filter "genre", "", @page_size
    assert_filter "genre", genres(:horror).id, @page_size
    assert_filter "genre", genres(:fantasy).id, 2
    assert_filter "genre", genres(:romance).id, 2
    assert_filter "genre", genres(:childrens).id, 1
  end

  test "search is case insensitive" do
    get books_path
    assert_select "input[id='title']"
    assert_filter "title", "fourth", 1
    assert_filter "title", "", @page_size
    assert_filter "title", "Fourth", 1
  end

  test "search and filters work together to filter" do
    assert_filter "title", "ng", 2

    get books_path, params: { "title": "ng", "owner": owners(:zach).id }
    assert_select "tr[aria-label='book row']"
  end

  private

  def assert_filter(param, value, count)
    get books_path, params: { "#{param}": value }
    assert_select "tr[aria-label='book row']", count
  end
end
