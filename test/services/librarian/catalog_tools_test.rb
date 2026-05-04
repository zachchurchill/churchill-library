require "test_helper"

class Librarian::CatalogToolsTest < ActiveSupport::TestCase
  def setup
    @tools = Librarian::CatalogTools.new
  end

  test "searches books with case insensitive sanitized sql like matching" do
    result = @tools.search_books(query: "WING")

    assert_equal false, result["truncated"]
    assert_equal [books(:fourthwing).id], result["books"].map { |book| book["id"] }

    wildcard_result = @tools.search_books(query: "%")

    assert_equal false, wildcard_result["truncated"]
    assert_empty wildcard_result["books"]
  end

  test "filters books by owner author and genre" do
    owner_result = @tools.list_books_by_owner(owner: "COURT")
    assert_equal [books(:fourthwing).id, books(:ironflame).id].sort,
                 owner_result["books"].map { |book| book["id"] }.sort

    author_result = @tools.list_books_by_author(author: "king")
    assert_equal [books(:shining).id, books(:it).id].sort,
                 author_result["books"].map { |book| book["id"] }.sort

    genre_result = @tools.list_books_by_genre(genre: "romance")
    assert_equal [books(:fourthwing).id, books(:ironflame).id].sort,
                 genre_result["books"].map { |book| book["id"] }.sort
  end

  test "caps book results and reports truncation" do
    result = @tools.list_books_by_author(author: "erb")

    assert_equal Librarian::CatalogTools::MAX_RESULTS, result["books"].size
    assert_equal true, result["truncated"]
    assert_equal result["books"].map { |book| book["id"] }.sort,
                 result["books"].map { |book| book["id"] }
  end

  test "returns catalog counts" do
    result = @tools.book_counts

    assert_equal Book.count, result["total_books"]
    assert_equal false, result["truncated"]
    assert_equal 2, count_for(result["owners"], "owner", "Zach")
    assert_equal 2, count_for(result["owners"], "owner", "Courtney")
    assert_equal 50, count_for(result["owners"], "owner", "System")
    assert_equal 2, count_for(result["authors"], "author", "Stephen King")
    assert_equal 50, count_for(result["authors"], "author", "Erb")
    assert_equal 52, count_for(result["genres"], "genre", "Horror")
    assert_equal 2, count_for(result["genres"], "genre", "Fantasy")
    assert_equal 2, count_for(result["genres"], "genre", "Romance")
  end

  private

  def count_for(group, label, name)
    group["rows"].find { |row| row[label] == name }.fetch("book_count")
  end
end
