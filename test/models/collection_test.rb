require "test_helper"

class CollectionTest < ActiveSupport::TestCase
  def setup
    @book = Collection.new(owner: "librarian", title: "book", author: "itself")
    @genre = @book.genres.build(name: "metafiction")
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

  test "unique owners returns expected based on test fixtures " do
    assert_equal 5, Collection.all.length # test fixtures
    assert_equal 3, Collection.unique_owners.length
    assert_includes Collection.unique_owners, "zach"
    assert_includes Collection.unique_owners, "courtney"
    assert_includes Collection.unique_owners, "penelope"
  end

  test "unique authors returns expected based on test fixtures " do
    assert_equal 5, Collection.all.length # test fixtures
    assert_equal 3, Collection.unique_authors.length
    assert_includes Collection.unique_authors, "stephen king"
    assert_includes Collection.unique_authors, "rebecca yarros"
    assert_includes Collection.unique_authors, "dr. seuss"
  end
end
