module Librarian
  class CatalogTools
    MAX_RESULTS = 25
    TOOL_DEFINITIONS = [
      {
        "type" => "function",
        "name" => "search_books",
        "description" => "Search books by title, owner, author, or genre text.",
        "parameters" => {
          "type" => "object",
          "properties" => {
            "query" => {
              "type" => "string",
              "description" => "Search text to match against title, owner, author, or genre."
            }
          },
          "required" => ["query"],
          "additionalProperties" => false
        }
      },
      {
        "type" => "function",
        "name" => "list_books_by_owner",
        "description" => "List books whose owner name matches the provided text.",
        "parameters" => {
          "type" => "object",
          "properties" => {
            "owner" => {
              "type" => "string",
              "description" => "Owner name to search for."
            }
          },
          "required" => ["owner"],
          "additionalProperties" => false
        }
      },
      {
        "type" => "function",
        "name" => "list_books_by_author",
        "description" => "List books whose author name matches the provided text.",
        "parameters" => {
          "type" => "object",
          "properties" => {
            "author" => {
              "type" => "string",
              "description" => "Author name to search for."
            }
          },
          "required" => ["author"],
          "additionalProperties" => false
        }
      },
      {
        "type" => "function",
        "name" => "list_books_by_genre",
        "description" => "List books whose genre name matches the provided text.",
        "parameters" => {
          "type" => "object",
          "properties" => {
            "genre" => {
              "type" => "string",
              "description" => "Genre name to search for."
            }
          },
          "required" => ["genre"],
          "additionalProperties" => false
        }
      },
      {
        "type" => "function",
        "name" => "book_counts",
        "description" => "Return total books and grouped book counts by owner, author, and genre.",
        "parameters" => {
          "type" => "object",
          "properties" => {},
          "additionalProperties" => false
        }
      }
    ].freeze

    def self.definitions
      TOOL_DEFINITIONS
    end

    def call(tool_name, arguments = {})
      case tool_name.to_s
      when "search_books"
        search_books(query: argument(arguments, :query, :q, :text))
      when "list_books_by_owner"
        list_books_by_owner(owner: argument(arguments, :owner, :owner_name, :name, :query))
      when "list_books_by_author"
        list_books_by_author(author: argument(arguments, :author, :author_name, :name, :query))
      when "list_books_by_genre"
        list_books_by_genre(genre: argument(arguments, :genre, :genre_name, :name, :query))
      when "book_counts"
        book_counts
      else
        raise ArgumentError, "unknown librarian catalog tool: #{tool_name}"
      end
    end

    def search_books(query:)
      pattern = like_pattern(query)

      books_response(
        base_books
          .left_joins(:genres)
          .where(
            "LOWER(books.title) LIKE :query OR " \
              "LOWER(owners.name) LIKE :query OR " \
              "LOWER(authors.name) LIKE :query OR " \
              "LOWER(genres.name) LIKE :query",
            query: pattern
          )
          .distinct
      )
    end

    def list_books_by_owner(owner:)
      books_response(
        base_books
          .where("LOWER(owners.name) LIKE ?", like_pattern(owner))
      )
    end

    def list_books_by_author(author:)
      books_response(
        base_books
          .where("LOWER(authors.name) LIKE ?", like_pattern(author))
      )
    end

    def list_books_by_genre(genre:)
      books_response(
        base_books
          .joins(:genres)
          .where("LOWER(genres.name) LIKE ?", like_pattern(genre))
          .distinct
      )
    end

    def book_counts
      owners = grouped_counts(
        Owner.joins(:books)
             .select("owners.*, COUNT(DISTINCT books.id) AS book_count")
             .group("owners.id")
             .order(Arel.sql("LOWER(owners.name), owners.id"))
             .readonly,
        "owner"
      )
      authors = grouped_counts(
        Author.joins(:books)
              .select("authors.*, COUNT(DISTINCT books.id) AS book_count")
              .group("authors.id")
              .order(Arel.sql("LOWER(authors.name), authors.id"))
              .readonly,
        "author"
      )
      genres = grouped_counts(
        Genre.joins(:books)
             .select("genres.*, COUNT(DISTINCT books.id) AS book_count")
             .group("genres.id")
             .order(Arel.sql("LOWER(genres.name), genres.id"))
             .readonly,
        "genre"
      )

      {
        "total_books" => Book.count,
        "owners" => owners,
        "authors" => authors,
        "genres" => genres,
        "truncated" => owners["truncated"] || authors["truncated"] || genres["truncated"]
      }
    end

    private

    def argument(arguments, *keys)
      arguments ||= {}

      keys.each do |key|
        return arguments[key] if arguments.key?(key)

        string_key = key.to_s
        return arguments[string_key] if arguments.key?(string_key)
      end

      nil
    end

    def base_books
      Book.joins(:owner, :author)
          .includes(:owner, :author, :genres)
          .readonly
    end

    def books_response(relation)
      records = relation.order(:id).limit(MAX_RESULTS + 1).to_a
      truncated = records.length > MAX_RESULTS

      {
        "books" => records.first(MAX_RESULTS).map { |book| book_row(book) },
        "truncated" => truncated
      }
    end

    def book_row(book)
      {
        "id" => book.id,
        "owner" => book.owner.name,
        "title" => book.title,
        "author" => book.author.name,
        "genres" => book.genres.sort_by { |genre| genre.name.downcase }.map(&:name)
      }
    end

    def grouped_counts(relation, label)
      records = relation.limit(MAX_RESULTS + 1).to_a
      truncated = records.length > MAX_RESULTS

      {
        "rows" => records.first(MAX_RESULTS).map do |record|
          {
            "id" => record.id,
            label => record.name,
            "book_count" => record.book_count.to_i
          }
        end,
        "truncated" => truncated
      }
    end

    def like_pattern(value)
      "%#{ActiveRecord::Base.sanitize_sql_like(value.to_s.strip.downcase)}%"
    end
  end
end
