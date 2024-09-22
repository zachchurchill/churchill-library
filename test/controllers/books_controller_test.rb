require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @expected_password = "foobar123!"
    @user = users(:librarian)
  end

  test "should get show" do
    get books_path
    assert_response :success
    assert_select "title", "Collections | #{root_title}"
  end

  test "should get add" do
    login
    get book_path
    assert_response :success
    assert_select "title", "Add Book | #{root_title}"
  end

  test "correctly adds book upon page submission" do
    login
    genre = generate_random_string(8)
    new_book = {
      owner: generate_random_string(5),
      title: generate_random_string(20),
      author: generate_random_string(10),
      genres: genre
    }
    post book_path, params: new_book
    assert_not_nil Owner.find_by(name: new_book[:owner])
    assert_not_nil Author.find_by(name: new_book[:author])
    assert_not_nil Genre.find_by(name: genre)
    assert_not_nil Book.find_by(title: new_book[:title])

    main_genre = generate_random_string(9)
    sub_genre = generate_random_string(7)
    another_book = {
      owner: generate_random_string(10),
      title: generate_random_string(40),
      author: generate_random_string(12),
      genres: "#{main_genre}, #{sub_genre}"
    }
    post book_path, params: another_book
    assert_not_nil Owner.find_by(name: another_book[:owner])
    assert_not_nil Author.find_by(name: another_book[:author])
    assert_not_nil Genre.find_by(name: main_genre)
    assert_not_nil Genre.find_by(name: sub_genre)
    assert_not_nil Book.find_by(title: another_book[:title])
  end

  test "multiple books for owner uses same owner record" do
    login
    owner = generate_random_string(5)
    new_book = {
      title: generate_random_string(20),
      owner: owner,
      author: generate_random_string(10),
      genres: generate_random_string(8)
    }
    assert_difference "Owner.count" do
      post book_path, params: new_book
    end

    another_book = {
      title: generate_random_string(24),
      owner: owner,
      author: generate_random_string(12),
      genres: generate_random_string(5)
    }
    assert_no_difference "Owner.count" do
      post book_path, params: another_book
    end
  end

  test "multiple books for author uses same author record" do
    login
    author = generate_random_string(5)
    new_book = {
      title: generate_random_string(20),
      owner: generate_random_string(10),
      author: author,
      genres: generate_random_string(8)
    }
    assert_difference "Author.count" do
      post book_path, params: new_book
    end

    another_book = {
      title: generate_random_string(24),
      owner: generate_random_string(12),
      author: author,
      genres: generate_random_string(5)
    }
    assert_no_difference "Author.count" do
      post book_path, params: another_book
    end
  end

  test "multiple books with overlapping genres uses same previous genre records" do
    login
    main_genre = generate_random_string(9)
    sub_genre = generate_random_string(7)
    new_book = {
      title: generate_random_string(20),
      owner: generate_random_string(14),
      author: generate_random_string(10),
      genres: "#{main_genre}, #{sub_genre}"
    }
    assert_difference "Genre.count", 2 do
      post book_path, params: new_book
    end

    other_sub_genre = generate_random_string(12)
    another_book = {
      title: generate_random_string(24),
      owner: generate_random_string(14),
      author: generate_random_string(12),
      genres: "#{main_genre}, #{other_sub_genre}"
    }
    assert_difference "Genre.count" do
      post book_path, params: another_book
    end

    final_book = {
      title: generate_random_string(34),
      owner: generate_random_string(4),
      author: generate_random_string(19),
      genres: "#{sub_genre}, #{other_sub_genre}"
    }
    assert_no_difference "Genre.count" do
      post book_path, params: final_book
    end
  end

  private

  def generate_random_string(length)
    alphabet = "abcdefghijklmnopqrstuvwxyz".split("")
    (1..length).map { alphabet.sample }.join
  end

  def login
    get admin_path
    post admin_path, params: { session: { username: @user.name, password: @expected_password } }
    assert logged_in?
  end
end
