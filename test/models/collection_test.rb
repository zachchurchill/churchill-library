require "test_helper"

class CollectionTest < ActiveSupport::TestCase
  def setup
    @book = Collection.new(owner: "librarian", title: "book", author: "itself", genre: "metafiction")
  end

  test "should be valid" do
    assert @book.valid?
  end

  test "owner should be present" do
    @book.owner = nil
    assert_not @book.valid?
  end

  test "owner should be >= 3 && <= 50 characters" do
    @book.owner = "aa"
    assert_not @book.valid?

    @book.owner = "a" * 51
    assert_not @book.valid?
  end

  test "title should be present" do
    @book.title = nil
    assert_not @book.valid?
  end

  test "title should be >=3 && <= 200 characters" do
    @book.title = "a" * 2
    assert_not @book.valid?

    @book.title = "a" * 201
    assert_not @book.valid?
  end

  test "author should be present" do
    @book.author = nil
    assert_not @book.valid?
  end

  test "author should be >= 3 && <= 100 characters" do
    @book.author = "a" * 2
    assert_not @book.valid?

    @book.author = "a" * 101
    assert_not @book.valid?
  end

  test "genre does not have to be present" do
    @book.genre = nil
    assert @book.valid?
  end

  test "genre should be >= 3 && <= 50 characters" do
    @book.genre = "a" * 2
    assert_not @book.valid?

    @book.genre = "a" * 51
    assert_not @book.valid?
  end
end
