require "test_helper"

class CollectionBookTest < ActiveSupport::TestCase
  test "same book cannot be added to a collection twice" do
    duplicate = CollectionBook.new(collection: collections(:family_favorites), book: books(:shining))
    assert_not duplicate.valid?
  end
end
