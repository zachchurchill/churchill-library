ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml in a specific order
    fixtures :authors, :owners, :genres, :books, :users

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

    def monkeypatch_openai(method_name, response)
      if OpenAiServices.instance_methods(false).include?(method_name)
        OpenAiServices.define_method(method_name) do |_content|
          response
        end
      else
        raise "Expecting to monkeypatch :#{method_name} but it's not instance method"
      end
    end
  end
end
