require "test_helper"

class EmbedBookJobTest < ActiveJob::TestCase
  test "record added to book embedding table" do
    expected_embedding = (1..256).to_a

    # Likely brittle but monkeypatching :embed so that call not actually made
    expected_embed_method = :embed
    if OpenAiServices.instance_methods(false).include?(expected_embed_method)
      OpenAiServices.define_method(expected_embed_method) do |_content|
        expected_embedding
      end
    else
      raise "Expecting to monkeypatch :#{expected_embed_method} for EmbedBookJobTest but it's not instance method"
    end

    book = Book.new(title: generate_random_string(25), author: Author.first, owner: Owner.first)
    book.genres = [Genre.first]
    book.save
    assert_nil book.book_embedding
    perform_enqueued_jobs do
      EmbedBookJob.perform_later(book)
    end
    assert_not_nil book.reload.book_embedding
    assert_equal expected_embedding, book.book_embedding.embedding
  end
end
