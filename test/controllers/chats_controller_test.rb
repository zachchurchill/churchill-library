require "test_helper"

class ChatsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:librarian)
  end

  test "logged out user cannot chat" do
    post chat_path, params: { message: "What books are here?", history: "[]" }

    assert_redirected_to admin_path
  end

  test "logged in user can chat with browser supplied history" do
    log_in_as_librarian
    response = text_response("Courtney owns Fourth Wing.")

    with_fake_open_ai_client(responses: [response]) do
      post chat_path, params: {
        message: "What does Courtney own?",
        history: [{ role: "user", content: "Hi" }, { role: "assistant", content: "Hello" }].to_json
      }
    end

    assert_response :success
    assert_select "#librarian-chat-messages"
    assert_select "p", "What does Courtney own?"
    assert_select "p", "Courtney owns Fourth Wing."
    assert_select "input[name='history']"
  end

  test "blank message returns validation error without calling OpenAI" do
    log_in_as_librarian

    post chat_path, params: { message: " ", history: "[]" }

    assert_response :unprocessable_entity
    assert_select "#librarian-chat-messages"
    assert_select "input[name='history']"
  end

  test "OpenAI failure returns friendly unavailable response" do
    log_in_as_librarian

    with_fake_open_ai_client do
      post chat_path, params: { message: "What should I read?", history: "[]" }
    end

    assert_response :service_unavailable
    assert_select "p", Librarian::ChatService::FAILURE_MESSAGE
  end

  private

  def log_in_as_librarian
    get admin_path
    post admin_path, params: { session: { username: @user.name, password: "foobar123!" } }
    assert_redirected_to root_path
    follow_redirect!
    assert logged_in?
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
