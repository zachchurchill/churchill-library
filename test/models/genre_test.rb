require "test_helper"

class GenreTest < ActiveSupport::TestCase
  def setup
    @genre = Genre.new(name: "horror")
  end

  test "genre should be >= 3 && <= 50 characters" do
    @genre.name = "a" * 2
    assert_not @genre.valid?

    @genre.name = "a" * 51
    assert_not @genre.valid?
  end

  test "hyphens should be preserved in titleized name" do
    Genre.create(name: "non-fiction")
    genre = Genre.find_by(name: "non-fiction")
    assert_not_nil genre
    assert_equal "Non-Fiction", genre.name
  end
end
