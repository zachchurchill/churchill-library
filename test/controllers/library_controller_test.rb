require "test_helper"

class LibraryControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get library_home_url
    assert_response :success
    assert_select "title", "Churchill Library"
  end
end
