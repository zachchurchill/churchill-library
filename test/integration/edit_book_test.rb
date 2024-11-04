require "test_helper"

class EditBookTest < ActionDispatch::IntegrationTest
  def setup
    @expected_password = "foobar123!"
    @user = users(:librarian)
  end

  test "book is updated, redirects user back to books, and shows a flash" do
    # arrange
    login
    book = Book.first
    new_title = generate_random_string(15)

    # act
    put book_edit_path, params: {
      id: book.id,
      book: {
        owner: book.owner.name,
        author: book.author.name,
        title: new_title,
        genres: book.genres.join(", ")
      }
    }

    # assert
    assert_redirected_to books_path
    assert_not flash.empty?
    assert_equal new_title, Book.find(book.id).title
  end

  test "book embedding changes when book is updated" do
    # arrange
    login
    monkeypatch_openai(:embed, (1..256).to_a)
    book = Book.first
    perform_enqueued_jobs { EmbedBookJob.perform_now(book) } if book.book_embedding.nil?
    book.save!
    new_embedding = (10..265).to_a
    monkeypatch_openai(:embed, new_embedding)

    # act
    new_title = generate_random_string(15)
    perform_enqueued_jobs do
      put book_edit_path, params: {
        id: book.id,
        book: {
          owner: book.owner.name,
          author: book.author.name,
          title: new_title,
          genres: book.genres.join(", ")
        }
      }
    end

    # assert
    book = Book.find(book.id)
    assert_equal new_title, book.title
    assert_equal new_embedding, book.book_embedding.embedding
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
