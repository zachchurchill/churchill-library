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

  test "filters are applied before pagination" do
    get books_path, params: { title: "book_49", owner: owners(:system).id }
    assert_response :success
    assert_select "tr[aria-label='book row']", 1
    assert_select "td", text: "Book 49"
  end

  test "dropdown options are faceted by selected owner" do
    get books_path, params: { owner: owners(:courtney).id }
    assert_response :success

    assert_select "select[id='owner']>option", count: 5
    assert_select "select[id='author']>option", count: 2
    assert_select "select[id='author']>option[value='#{authors(:rebecca_yarros).id}']"
    assert_select "select[id='author']>option[value='#{authors(:stephen_king).id}']", count: 0
    assert_select "select[id='genre']>option", count: 3
    assert_select "select[id='genre']>option[value='#{genres(:fantasy).id}']"
    assert_select "select[id='genre']>option[value='#{genres(:romance).id}']"
    assert_select "select[id='genre']>option[value='#{genres(:horror).id}']", count: 0
  end

  test "dropdown options are faceted by selected author" do
    get books_path, params: { author: authors(:stephen_king).id }
    assert_response :success

    assert_select "select[id='owner']>option", count: 2
    assert_select "select[id='owner']>option[value='#{owners(:zach).id}']"
    assert_select "select[id='owner']>option[value='#{owners(:courtney).id}']", count: 0
    assert_select "select[id='author']>option", count: 5
    assert_select "select[id='genre']>option", count: 2
    assert_select "select[id='genre']>option[value='#{genres(:horror).id}']"
  end

  test "dropdown options are faceted by selected genre" do
    get books_path, params: { genre: genres(:fantasy).id }
    assert_response :success

    assert_select "select[id='owner']>option", count: 2
    assert_select "select[id='owner']>option[value='#{owners(:courtney).id}']"
    assert_select "select[id='author']>option", count: 2
    assert_select "select[id='author']>option[value='#{authors(:rebecca_yarros).id}']"
    assert_select "select[id='genre']>option", count: 5
  end

  test "clean urls exclude unused filters and default page" do
    get books_path, params: { title: "  fourth  ", owner: "", author: "", genre: "", page: "1" }
    assert_redirected_to books_path(title: "fourth")
    assert_equal 303, response.status
  end

  test "invalid filter ids are ignored" do
    get books_path, params: { title: "fourth", owner: "999999", author: "abc", genre: genres(:horror).id }
    assert_redirected_to books_path(title: "fourth", genre: genres(:horror).id)
  end

  test "turbo stream responses include canonical url header" do
    get books_path, params: { owner: "999999" }, headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_equal books_path, response.headers["X-Canonical-Url"]
    assert_includes response.body, "<turbo-stream"
  end

  private

  def assert_filter(param, value, count)
    if value.present?
      get books_path, params: { "#{param}": value }
    else
      get books_path
    end
    assert_select "tr[aria-label='book row']", count
  end
end
