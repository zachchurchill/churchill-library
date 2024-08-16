require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    random_name = (0...8).map { (65 + rand(26)).chr }.join
    @user = User.new(name: random_name, password: "foobar!1234", password_confirmation: "foobar!1234")
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

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 12
    assert_not @user.valid?
  end

  test "password should be at least 10 characters long" do
    @user.password = @user.password_confirmation = "a" * 9
    assert_not @user.valid?
  end

  test "password should have one letter, one symbol, and one digit" do
    @user.password = @user.password_confirmation = "oneletter!1"
    assert @user.valid?

    @user.password = @user.password_confirmation = "nodigit!here"
    assert_not @user.valid?

    @user.password = @user.password_confirmation = "nosymbol1234"
    assert_not @user.valid?

    @user.password = @user.password_confirmation = "123456789!!!"
    assert_not @user.valid?
  end
end
