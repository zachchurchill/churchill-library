require "test_helper"

class OwnerTest < ActiveSupport::TestCase
  def setup
    @owner = Owner.new(name: "tester")
  end

  test "should be valid" do
    assert @owner.valid?
  end

  test "name should be present" do
    @owner.name = nil
    assert_not @owner.valid?
  end

  test "name should be >= 3 && <= 50 characters" do
    @owner.name = "aa"
    assert_not @owner.valid?

    @owner.name = "a" * 51
    assert_not @owner.valid?
  end
end
