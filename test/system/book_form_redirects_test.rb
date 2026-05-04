require "application_system_test_case"

class BookFormRedirectsTest < ApplicationSystemTestCase
  def setup
    @user = users(:librarian)
    @expected_password = "foobar123!"
  end

  test "adding a book redirects to books page" do
    log_in_as_librarian
    visit book_path

    fill_in "Owner", with: "Zach"
    fill_in "Title", with: "redirect test book"
    fill_in "Author", with: "Test Author"
    fill_in "Genres", with: "Test Genre"
    click_button "Save"

    assert_current_path books_path, ignore_query: false
    assert_text "\"Redirect Test Book\" has been added"
  end

  test "editing a book redirects to books page" do
    log_in_as_librarian
    book = books(:shining)
    visit book_edit_path(id: book.id)

    fill_in "Title", with: "updated redirect test book"
    click_button "Save"

    assert_current_path books_path, ignore_query: false
    assert_text "\"Updated Redirect Test Book\" has been updated"
  end

  private

  def log_in_as_librarian
    visit admin_path
    fill_in "Username", with: @user.name
    fill_in "Password", with: @expected_password
    click_button "Login"
    assert_current_path root_path, ignore_query: false
  end
end
