class EmbedBookJob < ApplicationJob
  queue_as :default

  def perform(book)
    BookEmbeddingService.new(book, OpenAiServices.new).embed
  end
end
