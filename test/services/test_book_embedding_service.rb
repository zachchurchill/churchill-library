require "test_helper"

# Stub services provider to make assertions against
class StubServicesProvider
  attr_accessor :content

  def new
    @content = nil
  end

  def embed(content)
    @content = content
  end
end

class TestBookEmbeddingService < ActiveSupport::TestCase
  test "embedding function called using Book.to_s" do
    book = Book.first
    services_provider = StubServicesProvider.new
    service = BookEmbeddingService.new(book, services_provider)
    assert_nil services_provider.content
    service.embed
    assert_equal book.to_s, services_provider.content
  end
end
