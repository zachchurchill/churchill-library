require "test_helper"

class RemoveBookTest < ActionDispatch::IntegrationTest
  def setup
    @expected_password = "foobar123!"
    @user = users(:librarian)
  end

  test "book is removed, redirects user back to books, and shows a flash" do
    get admin_path
    post admin_path, params: { session: { username: @user.name, password: @expected_password } }
    assert_redirected_to books_path
    follow_redirect!
    assert logged_in?
    book = Book.first
    assert_difference "Book.count", -1 do
      delete book_remove_path, params: { id: book.id }
    end
    assert_redirected_to books_path
    assert_not flash.empty?
  end

  private

  def generate_random_string(length)
    alphabet = "abcdefghijklmnopqrstuvwxyz".split("")
    (1..length).map { alphabet.sample }.join
  end
end
