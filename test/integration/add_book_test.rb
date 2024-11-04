require "test_helper"

class AddBookTest < ActionDispatch::IntegrationTest
  def setup
    @expected_password = "foobar123!"
    @user = users(:librarian)
  end

  test "add book redirects back to the collections page after submission with flash" do
    login
    post book_path, params: { owner: "qwerty", title: "this is a test", author: "myself", genres: "meta" }
    assert_redirected_to books_path
    assert_not flash.empty?
  end

  test "user must be logged in to add books" do
    get book_path
    log_out
    new_book = {
      owner: generate_random_string(14),
      title: generate_random_string(25),
      author: generate_random_string(12),
      genres: generate_random_string(15)
    }
    assert_no_difference "Book.count" do
      post book_path, params: new_book
    end
    assert_redirected_to admin_path
    assert_not flash.empty?
  end

  test "embedding added after new book added" do
    # arrange
    login
    expected_embedding = (1..256).to_a
    monkeypatch_openai(:embed, expected_embedding)
    book_info = {
      owner: generate_random_string(12),
      title: generate_random_string(25),
      author: generate_random_string(10),
      genres: generate_random_string(6)
    }

    # act
    perform_enqueued_jobs do
      post book_path, params: book_info
    end

    # assert
    book = Book.find_by(title: book_info[:title])
    assert_not_nil book
    assert_not_nil book.book_embedding
    assert_equal expected_embedding, book.book_embedding.embedding
  end

  private

  def login
    get admin_path
    post admin_path, params: { session: { username: @user.name, password: @expected_password } }
    assert_redirected_to books_path
    follow_redirect!
    assert logged_in?
  end

  def generate_random_string(length)
    alphabet = "abcdefghijklmnopqrstuvwxyz".split("")
    (1..length).map { alphabet.sample }.join
  end
end
