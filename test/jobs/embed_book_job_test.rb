require "test_helper"

class EmbedBookJobTest < ActiveJob::TestCase
  test "record added to book embedding table" do
    expected_embedding = (1..256).to_a
    monkeypatch_openai(:embed, expected_embedding)

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
