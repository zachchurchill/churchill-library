require "openai"

class BookEmbeddingService
  attr_reader :book

  def initialize(book)
    @book = book
  end

  def embed
    puts "Embedding #{@book}..."
    puts generate_embedding(@book.to_s)
  end

  private

  def generate_embedding(content)
    # TODO: Think more how to separate this or make it easier to test
    client = OpenAI::Client.new(access_token: Rails.application.credentials.api_keys.openai)
    embedding = client.embeddings(
      parameters: {
        model: "text-embedding-3-small",
        input: content,
        dimensions: 20
      }
    )
    embedding.dig("data", 0, "embedding")
  end
end
