# Creates or updates a vector embedding for the provided book
class BookEmbeddingService
  attr_reader :book, :services_provider

  def initialize(book, services_provider)
    @book = book
    @services_provider = services_provider
  end

  def embed
    embedding = @services_provider.embed(@book.to_s)
    if @book.book_embedding.present?
      @book.book_embedding.embedding = embedding
    else
      @book.book_embedding = BookEmbedding.new(embedding: embedding)
    end
    @book.book_embedding.save!
  end
end
