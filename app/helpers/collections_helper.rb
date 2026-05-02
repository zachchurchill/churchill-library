module CollectionsHelper
  def collection_summary(collection)
    books = collection.books.to_a
    author_count = books.map(&:author_id).uniq.size
    genre_count = books.flat_map(&:genres).map(&:id).uniq.size

    "Contains #{pluralize(books.size, "book")}, from #{pluralize(author_count, "author")}, spanning #{pluralize(genre_count, "genre")}"
  end
end
