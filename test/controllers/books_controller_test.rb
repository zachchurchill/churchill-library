require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:librarian)
    get admin_path
    post admin_path, params: { session: { username: @user.name, password: "foobar123!" } }
    assert logged_in?
  end

  test "should get show" do
    get books_path
    assert_response :success
    assert_select "title", "Collections | #{root_title}"
  end

  test "should get add" do
    get book_path
    assert_response :success
    assert_select "title", "Add Book | #{root_title}"
  end

  test "should get edit" do
    get book_edit_path, params: { id: Book.first.id }
    assert_response :success
    assert_select "title", "Edit Book | #{root_title}"
  end

  test "should get remove" do
    get book_remove_path, params: { id: Book.first.id }
    assert_response :success
    assert_select "title", "Remove Book | #{root_title}"
  end

  test "correctly adds book upon page submission" do
    genre = generate_random_string
    new_book = {
      owner: generate_random_string,
      title: generate_random_string,
      author: generate_random_string,
      genres: genre
    }
    post book_path, params: new_book
    assert_not_nil Owner.find_by(name: new_book[:owner])
    assert_not_nil Author.find_by(name: new_book[:author])
    assert_not_nil Genre.find_by(name: genre)
    assert_not_nil Book.find_by(title: new_book[:title])

    main_genre = generate_random_string
    sub_genre = generate_random_string
    another_book = {
      owner: generate_random_string,
      title: generate_random_string,
      author: generate_random_string,
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
    owner = generate_random_string
    new_book = {
      title: generate_random_string,
      owner: owner,
      author: generate_random_string,
      genres: generate_random_string
    }
    assert_difference "Owner.count" do
      post book_path, params: new_book
    end

    another_book = {
      title: generate_random_string,
      owner: owner,
      author: generate_random_string,
      genres: generate_random_string
    }
    assert_no_difference "Owner.count" do
      post book_path, params: another_book
    end
  end

  test "multiple books for author uses same author record" do
    author = generate_random_string
    new_book = {
      title: generate_random_string,
      owner: generate_random_string,
      author: author,
      genres: generate_random_string
    }
    assert_difference "Author.count" do
      post book_path, params: new_book
    end

    another_book = {
      title: generate_random_string,
      owner: generate_random_string,
      author: author,
      genres: generate_random_string
    }
    assert_no_difference "Author.count" do
      post book_path, params: another_book
    end
  end

  test "multiple books with overlapping genres uses same previous genre records" do
    main_genre = generate_random_string
    sub_genre = generate_random_string
    new_book = {
      title: generate_random_string,
      owner: generate_random_string,
      author: generate_random_string,
      genres: "#{main_genre}, #{sub_genre}"
    }
    assert_difference "Genre.count", 2 do
      post book_path, params: new_book
    end

    other_sub_genre = generate_random_string
    another_book = {
      title: generate_random_string,
      owner: generate_random_string,
      author: generate_random_string,
      genres: "#{main_genre}, #{other_sub_genre}"
    }
    assert_difference "Genre.count" do
      post book_path, params: another_book
    end

    final_book = {
      title: generate_random_string,
      owner: generate_random_string,
      author: generate_random_string,
      genres: "#{sub_genre}, #{other_sub_genre}"
    }
    assert_no_difference "Genre.count" do
      post book_path, params: final_book
    end
  end

  test "owner reuse is case insensitive" do
    owner = generate_random_string
    new_book = {
      title: generate_random_string,
      owner: owner,
      author: generate_random_string,
      genres: generate_random_string
    }
    assert_difference "Owner.count" do
      post book_path, params: new_book
    end
    another_book = {
      title: generate_random_string,
      owner: owner.upcase,
      author: generate_random_string,
      genres: generate_random_string
    }
    assert_no_difference "Owner.count" do
      post book_path, params: another_book
    end
  end

  test "author reuse is case insensitive" do
    author = generate_random_string
    new_book = {
      title: generate_random_string,
      owner: generate_random_string,
      author: author,
      genres: generate_random_string
    }
    assert_difference "Author.count" do
      post book_path, params: new_book
    end
    another_book = {
      title: generate_random_string,
      owner: generate_random_string,
      author: author.upcase,
      genres: generate_random_string
    }
    assert_no_difference "Author.count" do
      post book_path, params: another_book
    end
  end

  test "genre reuse is case insensitive" do
    genre = generate_random_string
    new_book = {
      title: generate_random_string,
      owner: generate_random_string,
      author: generate_random_string,
      genres: genre
    }
    assert_difference "Genre.count" do
      post book_path, params: new_book
    end
    another_book = {
      title: generate_random_string,
      owner: generate_random_string,
      author: generate_random_string,
      genres: genre.upcase
    }
    assert_no_difference "Genre.count" do
      post book_path, params: another_book
    end
  end

  private

  def generate_random_string(length = nil)
    length = Random.rand(3..50) if length.nil?
    alphabet = "abcdefghijklmnopqrstuvwxyz".split("")
    (1..length).map { alphabet.sample }.join
  end
end
