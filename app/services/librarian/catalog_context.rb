module Librarian
  class CatalogContext
    HEADER = "id | owner | title | author | genres"

    def self.call(scope = Book.includes(:owner, :author, :genres))
      new(scope).call
    end

    def initialize(scope = Book.includes(:owner, :author, :genres))
      @scope = scope
    end

    def call
      ([HEADER] + rows).join("\n")
    end
    alias to_s call

    private

    attr_reader :scope

    def rows
      scope.order(:id).map do |book|
        [
          book.id,
          book.owner.name,
          book.title,
          book.author.name,
          format_genres(book)
        ].join(" | ")
      end
    end

    def format_genres(book)
      book.genres.sort_by { |genre| genre.name.downcase }.map(&:name).join(", ")
    end
  end
end
