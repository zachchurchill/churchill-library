require "test_helper"

class Librarian::ChatServiceTest < ActiveSupport::TestCase
  test "creates a stateless responses request with catalog instructions and history" do
    response = text_response("Courtney owns Fourth Wing.")
    with_fake_open_ai_client(responses: [response]) do |client|
      result = Librarian::ChatService.new(client: client, catalog_context: "id | owner | title | author | genres").call(
        message: "What does Courtney own?",
        history: [{ "role" => "user", "content" => "Hi" }, { "role" => "assistant", "content" => "Hello" }]
      )

      assert_equal "Courtney owns Fourth Wing.", result.assistant_message
      assert_equal false, result.failed?
      request = client.response_calls.first
      assert_equal "gpt-5-mini", request[:model]
      assert_equal false, request[:store]
      assert_not request.key?(:temperature)
      assert_includes request[:instructions], "id | owner | title | author | genres"
      assert_equal ["search_books", "list_books_by_owner", "list_books_by_author", "list_books_by_genre", "book_counts"],
                   request[:tools].map { |tool| tool["name"] }
      assert_equal "What does Courtney own?", request[:input].last["content"]
    end
  end

  test "executes tool calls and sends tool output into the next stateless response" do
    tool_call_response = {
      "id" => "resp_tool",
      "output" => [
        {
          "type" => "function_call",
          "call_id" => "call_1",
          "name" => "list_books_by_genre",
          "arguments" => { genre: "romance" }.to_json
        }
      ]
    }
    final_response = text_response("The romance books are Fourth Wing and Iron Flame.")

    with_fake_open_ai_client(responses: [tool_call_response, final_response]) do |client|
      result = Librarian::ChatService.new(client: client).call(message: "Show romance books", history: [])

      assert_equal "The romance books are Fourth Wing and Iron Flame.", result.assistant_message
      assert_equal 2, client.response_calls.length

      second_input = client.response_calls.second[:input]
      tool_output = second_input.find { |item| item["type"] == "function_call_output" }
      assert_equal "call_1", tool_output["call_id"]
      parsed_output = JSON.parse(tool_output["output"])
      assert_equal false, parsed_output["truncated"]
      assert_includes parsed_output["books"].map { |book| book["title"] }, "fourth wing"
      assert_includes parsed_output["books"].map { |book| book["title"] }, "iron flame"
    end
  end

  test "returns a friendly failure when the OpenAI client raises" do
    with_fake_open_ai_client do |client|
      result = Librarian::ChatService.new(client: client).call(message: "What should I read?", history: [])

      assert_equal true, result.failed?
      assert_equal Librarian::ChatService::FAILURE_MESSAGE, result.assistant_message
      assert_equal "assistant", result.messages.last["role"]
      assert_equal Librarian::ChatService::FAILURE_MESSAGE, result.messages.last["content"]
    end
  end

  private

  def text_response(text)
    {
      "id" => "resp_text",
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
