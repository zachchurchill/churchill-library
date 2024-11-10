require "test_helper"

class ChatHelperTest < ActiveSupport::TestCase
  test "conversation provides messages correctly for OpenAI API" do
    convo = ChatHelper::Conversation.new
    convo.add_user_message("Hi")
    convo.add_assistant_message("Hi. How may I help?")
    expected_messages = [
      { role: "user", content: "Hi" },
      { role: "assistant", content: "Hi. How may I help?" }
    ]
    assert_equal expected_messages, convo.messages
  end

  test "user must follow assistant message" do
    convo = ChatHelper::Conversation.new
    convo.add_user_message("Hi")
    convo.add_assistant_message("Hi. How may I help?")
    assert_raises(ChatHelper::MessageOrderError, match: /user/i) do
      convo.add_assistant_message("I am awfully chatty")
    end
  end

  test "assistant must follow user message" do
    convo = ChatHelper::Conversation.new
    convo.add_user_message("Hi")
    assert_raises(ChatHelper::MessageOrderError, match: /assistant/i) do
      convo.add_user_message("Oh wait I have a question")
    end
  end
end
