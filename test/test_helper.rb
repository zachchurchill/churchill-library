ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

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
  end
end
