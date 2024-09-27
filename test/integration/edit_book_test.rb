require "test_helper"

class EditBookTest < ActionDispatch::IntegrationTest
  def setup
    @expected_password = "foobar123!"
    @user = users(:librarian)
  end

  test "book is updated, redirects user back to books, and shows a flash" do
    get admin_path
    post admin_path, params: { session: { username: @user.name, password: @expected_password } }
    assert_redirected_to books_path
    follow_redirect!
    assert logged_in?
    book = Book.first
    new_title = generate_random_string(15)
    put book_edit_path, params: {
      id: book.id,
      book: {
        owner: book.owner.name,
        author: book.author.name,
        title: new_title,
        genres: book.genres.join(", ")
      }
    }
    assert_redirected_to books_path
    assert_not flash.empty?
    assert_equal new_title, Book.find(book.id).title
  end

  private

  def generate_random_string(length)
    alphabet = "abcdefghijklmnopqrstuvwxyz".split("")
    (1..length).map { alphabet.sample }.join
  end
end
