require "application_system_test_case"

class LibrarianChatTest < ApplicationSystemTestCase
  def setup
    @user = users(:librarian)
  end

  test "logged out users do not see chat" do
    visit books_path

    assert_no_selector "#ai-chat"
    assert_no_selector "#librarian-chat-panel"
  end

  test "logged in user can open close and submit librarian chat" do
    log_in_as_librarian

    with_fake_open_ai_client(responses: [text_response("Courtney owns Fourth Wing.")], shared: true) do
      visit books_path
      click_button "Chat with Librarian"

      assert_selector "#librarian-chat-panel"
      fill_in "librarian-chat-message", with: "What does Courtney own?"
      click_button "Send"

      assert_text "What does Courtney own?"
      assert_text "Courtney owns Fourth Wing."

      click_button "Close"
      assert_no_text "Courtney owns Fourth Wing."
      click_button "Chat with Librarian"
      assert_text "Courtney owns Fourth Wing."

      refresh
      click_button "Chat with Librarian"
      assert_text "Courtney owns Fourth Wing."
    end
  end

  private

  def log_in_as_librarian
    visit admin_path
    fill_in "Username", with: @user.name
    fill_in "Password", with: "foobar123!"
    click_button "Login"
  end

  def text_response(text)
    {
      "output" => [
        {
          "type" => "message",
          "role" => "assistant",
          "content" => [
            { "type" => "output_text", "text" => text }
          ]
        }
      ]
    }
  end
end
