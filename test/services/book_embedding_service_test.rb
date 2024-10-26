require "test_helper"

# Stub services provider to make assertions against
class StubServicesProvider
  attr_accessor :content

  def new
    @content = nil
  end

  def embed(content)
    @content = content
    (1..256).to_a
  end
end

class TestBookEmbeddingService < ActiveSupport::TestCase
  def setup
    @services_provider = StubServicesProvider.new
    @book = Book.new(title: generate_random_string(25), author: Author.first, owner: Owner.first)
    @book.genres = [Genre.first]
    @book.save
  end

  test "embedding function called using Book.to_s" do
    assert_nil @services_provider.content
    BookEmbeddingService.new(@book, @services_provider).embed
    assert_equal @book.to_s, @services_provider.content
  end

  test "new book embedding record added for book" do
    assert_difference "BookEmbedding.count" do
      BookEmbeddingService.new(@book, @services_provider).embed
    end
  end

  test "book with previous embedding just updates existing record" do
    BookEmbeddingService.new(@book, @services_provider).embed
    book_embedding_id = @book.book_embedding.id
    @book.author = Author.new(name: "for book embed test")
    @book.save
    assert_no_difference "BookEmbedding.count" do
      BookEmbeddingService.new(@book, @services_provider).embed
    end
    assert_equal book_embedding_id, @book.book_embedding.id
  end
end
