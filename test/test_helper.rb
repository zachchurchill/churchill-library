ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

Dir[Rails.root.join("test/support/**/*.rb").to_s].sort.each { |file| require file }

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml in a specific order
    fixtures :authors, :owners, :genres, :books, :users, :collections, :collection_books

    # Add more helper methods to be used by all tests here...
    def root_title
      "Churchill Library"
    end

    # Returns true if a test user is logged in.
    def logged_in?
      !session[:user_id].nil?
    end

    # Removes user from session
    def log_out
      session.delete(:user_id)
    end

    def generate_random_string(length)
      alphabet = "abcdefghijklmnopqrstuvwxyz".split("")
      (1..length).map { alphabet.sample }.join
    end

    def with_fake_open_ai_client(embeddings: [], responses: [])
      fake_client = FakeOpenAiClient.new(embeddings: embeddings, responses: responses)
      OpenAi::ClientFactory.with_client(fake_client) { yield fake_client }
    end
  end
end
