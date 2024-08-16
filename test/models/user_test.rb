require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    random_name = (0...8).map { (65 + rand(26)).chr }.join
    @user = User.new(name: random_name)
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "        "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "user names should be unique" do
    @user.save
    duplicated_user = @user.dup
    assert_not duplicated_user.valid?
  end
end
