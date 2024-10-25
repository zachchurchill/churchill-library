# Creates or updates a vector embedding for the provided book
class BookEmbeddingService
  attr_reader :book, :services_provider

  def initialize(book, services_provider)
    @book = book
    @services_provider = services_provider
  end

  def embed
    puts "Embedding #{@book}..."
    embedding = @services_provider.embed(@book.to_s)
  end
end
