require "test_helper"

class CollectionTest < ActiveSupport::TestCase
  def setup
    @collection = Collection.new(
      owner: owners(:zach),
      title: "summer reads",
      description: "Books for a summer reading list."
    )
    @collection.books << books(:shining)
  end

  test "should be valid" do
    assert @collection.valid?
  end

  test "title should be present" do
    @collection.title = nil
    assert_not @collection.valid?
  end

  test "owner should be present" do
    @collection.owner = nil
    assert_not @collection.valid?
  end

  test "description is optional" do
    @collection.description = nil
    assert @collection.valid?
  end

  test "must include at least one book" do
    @collection.books = []
    assert_not @collection.valid?
  end

  test "title is normalized before save" do
    @collection.title = "Summer Reads"
    @collection.save!
    assert_equal "summer reads", @collection.reload.title
  end
end
