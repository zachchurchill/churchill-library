require "application_system_test_case"

class BooksFilteringTest < ApplicationSystemTestCase
  test "typing in title filters without pressing enter" do
    visit books_path

    fill_in "title", with: "fourth"

    assert_text "Fourth Wing"
    assert_no_text "The Shining"
    assert_current_path books_path(title: "fourth"), ignore_query: false
  end

  test "selecting owner narrows author and genre dropdowns" do
    visit books_path

    select "Courtney", from: "owner"

    assert_current_path books_path(owner: owners(:courtney).id), ignore_query: false
    assert_selector "select#author option", text: "Rebecca Yarros"
    assert_no_selector "select#author option", text: "Stephen King"
    assert_selector "select#genre option", text: "Fantasy"
    assert_selector "select#genre option", text: "Romance"
    assert_no_selector "select#genre option", text: "Horror"
  end

  test "clearing filter removes it from the url" do
    visit books_path(owner: owners(:courtney).id)

    select "All Owners", from: "owner"

    assert_current_path books_path, ignore_query: false
  end
end
