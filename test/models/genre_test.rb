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

  test "unique genres returns expected based on test fixtures " do
    assert_equal 4, Genre.all.length # test fixtures
    assert_equal 4, Genre.unique_genres.length
    assert_includes Genre.unique_genres, "horror"
    assert_includes Genre.unique_genres, "fantasy"
    assert_includes Genre.unique_genres, "romance"
    assert_includes Genre.unique_genres, "childrens"
  end
end
