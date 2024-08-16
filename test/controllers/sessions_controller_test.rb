require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get admin_path
    assert_response :success
    assert_select "title", "Admin | #{root_title}"
  end
end
