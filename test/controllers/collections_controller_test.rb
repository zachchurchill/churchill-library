require "test_helper"

class CollectionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:librarian)
    @expected_password = "foobar123!"
  end

  test "should get index" do
    get collections_path
    assert_response :success
    assert_select "title", "Collections | #{root_title}"
    assert_select "h1", "Collections"
    assert_select "p", "Explore our family reading Collections through the curated lists below."
    assert_select "select[id='owner']"
    assert_select "article[aria-label='collection card']", 2
    assert_select "p", "Contains 2 books, from 2 authors, spanning 3 genres"
    assert_select "p", "Contains 2 books, from 1 author, spanning 2 genres"
    assert_select "p", "Zach"
    assert_select "p", "Courtney"
    assert_select "a[href=?]", collection_path(collections(:family_favorites))
    assert_select "a[href=?]", collection_path(collections(:dragon_books))
    assert_select "a[href=?]", edit_collection_path(collections(:family_favorites)), count: 0
    assert_select "a[href=?]", collections_path
    assert_select "a[href=?]", new_collection_path, count: 0
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
    assert_select "a[href=?]", collections_path, text: "Back"
    assert_select "a[href=?]", edit_collection_path(collections(:family_favorites)), count: 0
    assert_select "h1", "Family Favorites"
    assert_select "section#top-matter p", "Contains 2 books, from 2 authors, spanning 3 genres"
    assert_select "li[aria-label='collection book']", 2
    assert_select "li[aria-label='collection book'] p", "The Shining"
    assert_select "li[aria-label='collection book'] p", "by Stephen King"
    assert_select "li[aria-label='collection book'] span", "Horror"
    assert_select "li[aria-label='collection book'] p", "Fourth Wing"
    assert_select "li[aria-label='collection book'] p", "by Rebecca Yarros"
    assert_select "li[aria-label='collection book'] span", "Fantasy"
    assert_select "li[aria-label='collection book'] span", "Romance"
  end

  test "logged in user should get new" do
    log_in_as_librarian
    get new_collection_path
    assert_response :success
    assert_select "title", "Add Collection | #{root_title}"
    assert_select "select[id='collection_owner_id']"
    assert_select "textarea[id='collection_title']"
    assert_select "textarea[id='collection_description']"
    assert_select "input[id='book_search']"
    assert_select "input[type='checkbox']", Book.count
  end

  test "logged in user should get edit" do
    log_in_as_librarian
    get edit_collection_path(collections(:family_favorites))

    assert_response :success
    assert_select "title", "Edit Collection | #{root_title}"
    assert_select "h1", "Edit \"Family Favorites\""
    assert_select "select[id='collection_owner_id']"
    assert_select "textarea[id='collection_title']"
    assert_select "textarea[id='collection_description']"
    assert_select "input[id='book_search']"
    assert_select "input[type='checkbox']", Book.count
    assert_select "form[action='#{collection_path(collections(:family_favorites))}'][method='post']"
  end

  test "logged out user cannot get new" do
    get new_collection_path
    assert_redirected_to admin_path
  end

  test "logged out user cannot get edit" do
    get edit_collection_path(collections(:family_favorites))
    assert_redirected_to admin_path
  end

  test "index shows add collection button for logged in user" do
    log_in_as_librarian
    get collections_path
    assert_response :success
    assert_select "a[href=?]", new_collection_path
    assert_select "a[href=?]", edit_collection_path(collections(:family_favorites))
  end

  test "show displays edit button for logged in user" do
    log_in_as_librarian
    get collection_path(collections(:family_favorites))
    assert_response :success

    assert_select "a[href=?]", edit_collection_path(collections(:family_favorites)), text: "Edit"
  end

  test "logged in user can create collection with books from any owner" do
    log_in_as_librarian
    book_ids = [books(:shining).id, books(:fourthwing).id]

    assert_no_difference "Book.count" do
      assert_difference "Collection.count" do
        assert_difference "CollectionBook.count", 2 do
          post collections_path, params: {
            collection: {
              owner_id: owners(:zach).id,
              title: "shared reads",
              description: "Books from the shared library.",
              book_ids: book_ids
            }
          }
        end
      end
    end

    collection = Collection.find_by(title: "shared reads")
    assert_redirected_to collection_path(collection)
    assert_equal owners(:zach), collection.owner
    assert_includes collection.books, books(:shining)
    assert_includes collection.books, books(:fourthwing)
  end

  test "logged in user can update collection details and books" do
    log_in_as_librarian
    collection = collections(:family_favorites)

    put collection_path(collection), params: {
      collection: {
        owner_id: owners(:courtney).id,
        title: "updated favorites",
        description: "A revised list.",
        book_ids: [books(:shining).id, books(:ironflame).id]
      }
    }

    assert_redirected_to collection_path(collection)
    collection.reload
    assert_equal owners(:courtney), collection.owner
    assert_equal "updated favorites", collection.title
    assert_equal "A revised list.", collection.description
    assert_equal [books(:shining).id, books(:ironflame).id].sort, collection.book_ids.sort
  end

  test "logged in user cannot update collection without books" do
    log_in_as_librarian
    collection = collections(:family_favorites)
    original_book_ids = collection.book_ids.sort

    put collection_path(collection), params: {
      collection: {
        owner_id: owners(:zach).id,
        title: "empty update",
        description: "No books selected.",
        book_ids: []
      }
    }

    assert_response :unprocessable_entity
    assert_template :edit
    assert_equal original_book_ids, collection.reload.book_ids.sort
  end

  test "logged out user cannot update collection" do
    collection = collections(:family_favorites)

    put collection_path(collection), params: {
      collection: {
        owner_id: owners(:courtney).id,
        title: "updated favorites",
        book_ids: [books(:shining).id]
      }
    }

    assert_redirected_to admin_path
    assert_equal "family favorites", collection.reload.title
  end

  test "logged in user cannot create collection without books" do
    log_in_as_librarian

    assert_no_difference "Collection.count" do
      post collections_path, params: {
        collection: {
          owner_id: owners(:zach).id,
          title: "empty list",
          description: "No books selected.",
          book_ids: []
        }
      }
    end

    assert_response :unprocessable_entity
    assert_template :new
  end

  test "logged out user cannot create collection" do
    assert_no_difference "Collection.count" do
      post collections_path, params: {
        collection: {
          owner_id: owners(:zach).id,
          title: "shared reads",
          book_ids: [books(:shining).id]
        }
      }
    end

    assert_redirected_to admin_path
  end

  test "logged in user can delete collection" do
    log_in_as_librarian

    assert_difference "Collection.count", -1 do
      delete collection_path(collections(:family_favorites))
    end

    assert_redirected_to collections_path
  end

  test "logged out user cannot delete collection" do
    assert_no_difference "Collection.count" do
      delete collection_path(collections(:family_favorites))
    end

    assert_redirected_to admin_path
  end

  private

  def log_in_as_librarian
    get admin_path
    post admin_path, params: { session: { username: @user.name, password: @expected_password } }
    assert_redirected_to root_path
    follow_redirect!
    assert logged_in?
  end
end
