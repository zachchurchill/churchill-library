require "test_helper"

class CollectionsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get collections_path
    assert_response :success
    assert_select "title", "Collections | #{root_title}"
  end

  test "should get add" do
    get book_path
    assert_response :success
    assert_select "title", "Add Book | #{root_title}"
  end

  test "correctly adds book upon page submission" do
    genre = generate_random_string(8)
    new_book = {
      owner: generate_random_string(5),
      title: generate_random_string(20),
      author: generate_random_string(10),
      genres: genre
    }
    post book_path, params: new_book
    assert_not_nil Genre.find_by(name: genre)
    assert_not_nil Collection.find_by(owner: new_book[:owner])
    assert_not_nil Collection.find_by(title: new_book[:title])
    assert_not_nil Collection.find_by(author: new_book[:author])

    main_genre = generate_random_string(9)
    sub_genre = generate_random_string(7)
    another_book = {
      owner: generate_random_string(10),
      title: generate_random_string(40),
      author: generate_random_string(12),
      genres: "#{main_genre}, #{sub_genre}"
    }
    post book_path, params: another_book
    assert_not_nil Genre.find_by(name: main_genre)
    assert_not_nil Genre.find_by(name: sub_genre)
    assert_not_nil Collection.find_by(owner: another_book[:owner])
    assert_not_nil Collection.find_by(title: another_book[:title])
    assert_not_nil Collection.find_by(author: another_book[:author])
  end

  private

  def generate_random_string(length)
    alphabet = "abcdefghijklmnopqrstuvwxyz".split("")
    (1..length).map { alphabet.sample }.join
  end
end
