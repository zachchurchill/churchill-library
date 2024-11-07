require "test_helper"

class RemoveBookTest < ActionDispatch::IntegrationTest
  def setup
    @expected_password = "foobar123!"
    @user = users(:librarian)
    get admin_path
    post admin_path, params: { session: { username: @user.name, password: @expected_password } }
    assert_redirected_to books_path
    follow_redirect!
    assert logged_in?
  end

  test "book is removed, redirects user back to books, and shows a flash" do
    book = Book.first
    assert_difference "Book.count", -1 do
      delete book_remove_path, params: { id: book.id }
    end
    assert_redirected_to books_path
    assert_not flash.empty?
  end

  test "book removal also removes owner if not attached to other books" do
    new_book = {
      owner: generate_random_string(15),
      title: generate_random_string(25),
      author: Book.first.author.name,
      genres: Book.first.genres.join(", ")
    }
    assert_difference "Book.count" do
      post book_path, params: new_book
    end
    assert_equal 1, Owner.where(name: new_book[:owner]).length
    new_book_id = Book.find_by(title: new_book[:title]).id
    assert_difference "Book.count", -1 do
      delete book_remove_path, params: { id: new_book_id }
    end
    assert_equal 0, Owner.where(name: new_book[:owner]).length
  end

  test "book removal also removes author if not attached to other books" do
    new_book = {
      owner: Book.first.owner.name,
      title: generate_random_string(25),
      author: generate_random_string(27),
      genres: Book.first.genres.join(", ")
    }
    assert_difference "Book.count" do
      post book_path, params: new_book
    end
    assert_equal 1, Author.where(name: new_book[:author]).length
    new_book_id = Book.find_by(title: new_book[:title]).id
    assert_difference "Book.count", -1 do
      delete book_remove_path, params: { id: new_book_id }
    end
    assert_equal 0, Author.where(name: new_book[:author]).length
  end

  test "book removal also removes genres if not attached to other books" do
    book_with_new_genre = {
      owner: Book.first.owner.name,
      title: generate_random_string(25),
      author: Book.first.author.name,
      genres: generate_random_string(7)
    }
    assert_difference "Book.count" do
      post book_path, params: book_with_new_genre
    end
    assert_equal 1, Genre.where(name: book_with_new_genre[:genres]).length
    new_book_id = Book.find_by(title: book_with_new_genre[:title]).id
    assert_difference "Book.count", -1 do
      delete book_remove_path, params: { id: new_book_id }
    end
    assert_equal 0, Genre.where(name: book_with_new_genre[:genres]).length

    new_genre = generate_random_string(12)
    existing_genre = Genre.first.name.downcase
    book_with_one_existing_genre = {
      owner: Book.first.owner.name,
      title: generate_random_string(25),
      author: Book.first.author.name,
      genres: "#{new_genre}, #{existing_genre}"
    }
    assert_difference "Book.count" do
      post book_path, params: book_with_one_existing_genre
    end
    assert_equal 1, Genre.where(name: existing_genre).length
    assert_equal 1, Genre.where(name: new_genre).length
    new_book_id = Book.find_by(title: book_with_one_existing_genre[:title]).id
    assert_difference "Book.count", -1 do
      delete book_remove_path, params: { id: new_book_id }
    end
    assert_equal 1, Genre.where(name: existing_genre).length
    assert_equal 0, Genre.where(name: new_genre).length
  end

  test "book removal also removes book embedding" do
    # arrange
    expected_embedding = (1..256).to_a
    monkeypatch_openai(:embed, expected_embedding)
    new_book = {
      owner: generate_random_string(15),
      title: generate_random_string(25),
      author: Book.first.author.name,
      genres: Book.first.genres.join(", ")
    }
    perform_enqueued_jobs do
      assert_difference "Book.count" do
        post book_path, params: new_book
      end
    end
    book = Book.find_by(title: new_book[:title])
    book_embedding = book.book_embedding

    # act
    assert_difference "Book.count", -1 do
      delete book_remove_path, params: { id: book.id }
    end
    assert_equal 0, BookEmbedding.where(id: book_embedding.id).length
  end

  private

  def generate_random_string(length)
    alphabet = "abcdefghijklmnopqrstuvwxyz".split("")
    (1..length).map { alphabet.sample }.join
  end
end
