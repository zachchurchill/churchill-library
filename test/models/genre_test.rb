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
end
