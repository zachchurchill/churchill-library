require "test_helper"

class AuthorTest < ActiveSupport::TestCase
  def setup
    @author = Author.new(name: "system")
  end

  test "should be valid" do
    assert @author.valid?
  end

  test "name should be present" do
    @author.name = nil
    assert_not @author.valid?
  end

  test "name should be >= 3 && <= 100 characters" do
    @author.name = "a" * 2
    assert_not @author.valid?

    @author.name = "a" * 101
    assert_not @author.valid?
  end
end
