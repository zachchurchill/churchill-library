require "test_helper"

class Librarian::CatalogContextTest < ActiveSupport::TestCase
  test "formats a compact catalog context with stable rows" do
    selected_books = [books(:fourthwing), books(:shining)].sort_by(&:id)
    scope = Book.where(id: selected_books.map(&:id)).includes(:owner, :author, :genres)

    expected = [
      "id | owner | title | author | genres",
      *selected_books.map { |book| formatted_row(book) }
    ].join("\n")

    assert_equal expected, Librarian::CatalogContext.new(scope).call
  end

  private

  def formatted_row(book)
    [
      book.id,
      book.owner.name,
      book.title,
      book.author.name,
      book.genres.sort_by { |genre| genre.name.downcase }.map(&:name).join(", ")
    ].join(" | ")
  end
end
