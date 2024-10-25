require "test_helper"

class BookTest < ActiveSupport::TestCase
  def setup
    @owner = Owner.new(name: "tester")
    @author = Author.new(name: "system")
    @book = Book.new(title: "book")
    @book.author = @author
    @book.owner = @owner
    @genre = @book.genres.build(name: "metafiction")
  end

  test "should be valid" do
    assert @book.valid?
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

  test "owner should be present" do
    @book.owner = nil
    assert_not @book.valid?
  end

  test "author should be present" do
    @book.author = nil
    assert_not @book.valid?
  end

  test "to_s provides expected representation" do
    assert_equal @book.to_s, "tester owns book written by system under the genres of metafiction"
    new_genre = Genre.create(name: "creepypasta")
    @book.genres = [@genre, new_genre]
    assert_equal @book.to_s, "tester owns book written by system under the genres of metafiction, creepypasta"
  end
end
