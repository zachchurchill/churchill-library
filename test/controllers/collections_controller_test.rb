require "test_helper"

class CollectionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get collections_path
    assert_response :success
    assert_select "title", "Collections | #{root_title}"
    assert_select "h1", "Collections"
    assert_select "p", "Explore our family reading Collections through the curated lists below."
    assert_select "select[id='owner']"
    assert_select "article[aria-label='collection card']", 2
    assert_select "a[href=?]", collection_path(collections(:family_favorites))
    assert_select "a[href=?]", collection_path(collections(:dragon_books))
    assert_select "a[href=?]", collections_path
    assert_select "a[href=?]", books_path, count: 0
  end

  test "owner filter limits collections" do
    get collections_path, params: { owner: owners(:courtney).id }
    assert_response :success

    assert_select "article[aria-label='collection card']", 1
    assert_select "h2", "Dragon Books"
    assert_select "h2", { text: "Family Favorites", count: 0 }
  end

  test "show renders collection books" do
    get collection_path(collections(:family_favorites))
    assert_response :success

    assert_select "title", "Family Favorites | #{root_title}"
    assert_select "h1", "Family Favorites"
    assert_select "li[aria-label='collection book']", 2
    assert_select "li", text: /The Shining/
    assert_select "li", text: /Stephen King/
    assert_select "li", text: /Zach/
    assert_select "li", text: /Fourth Wing/
    assert_select "li", text: /Courtney/
  end
end
