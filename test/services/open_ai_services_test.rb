require "test_helper"

class OpenAiServicesTest < ActiveSupport::TestCase
  class RecordingResponses
    attr_reader :parameters

    def initialize(response)
      @response = response
    end

    def create(parameters:)
      @parameters = parameters
      @response
    end
  end

  class RecordingOpenAiClient
    attr_reader :embedding_parameters, :responses

    def initialize(embedding_response:, response:)
      @embedding_response = embedding_response
      @responses = RecordingResponses.new(response)
    end

    def embeddings(parameters:)
      @embedding_parameters = parameters
      @embedding_response
    end
  end

  test "real client embeds with app embedding configuration" do
    expected_embedding = (1..256).to_a
    raw_client = RecordingOpenAiClient.new(
      embedding_response: { "data" => [{ "embedding" => expected_embedding }] },
      response: {}
    )

    embedding = OpenAi::RealClient.new(client: raw_client).embed("book text")

    assert_equal expected_embedding, embedding
    assert_equal(
      {
        model: "text-embedding-3-small",
        input: "book text",
        dimensions: 256
      },
      raw_client.embedding_parameters
    )
  end

  test "real client creates responses through ruby openai responses client" do
    expected_response = { "id" => "resp_123" }
    raw_client = RecordingOpenAiClient.new(
      embedding_response: {},
      response: expected_response
    )
    parameters = { model: "gpt-4o-mini", input: "hello" }

    response = OpenAi::RealClient.new(client: raw_client).create_response(parameters: parameters)

    assert_equal expected_response, response
    assert_equal parameters, raw_client.responses.parameters
  end

  test "compatibility service routes through current client seam" do
    expected_embedding = (1..256).to_a
    expected_response = { "id" => "resp_123", "output_text" => "Hello" }

    with_fake_open_ai_client(embeddings: [expected_embedding], responses: [expected_response]) do |client|
      service = OpenAiServices.new

      assert_equal expected_embedding, service.embed("book text")
      assert_equal expected_response, service.create_response(parameters: { model: "gpt-4o-mini", input: "hello" })
      assert_equal [
        { method: :embed, content: "book text" },
        { method: :create_response, parameters: { model: "gpt-4o-mini", input: "hello" } }
      ], client.calls
    end
  end

  test "compatibility chat uses responses api text output" do
    response = {
      "output" => [
        {
          "type" => "message",
          "role" => "assistant",
          "content" => [
            { "type" => "output_text", "text" => "Hello from Responses" }
          ]
        }
      ]
    }

    with_fake_open_ai_client(responses: [response]) do |client|
      conversation = ChatHelper::Conversation.new
      conversation.add_user_message("Hi")

      OpenAiServices.new.chat(conversation)

      assert_equal "Hello from Responses", conversation.messages.last[:content]
      request = client.response_calls.first
      assert_equal "gpt-5-mini", request[:model]
      assert_equal false, request[:store]
      assert_not request.key?(:temperature)
    end
  end
end
