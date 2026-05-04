require "json"

module Librarian
  class ChatService
    MODEL = "gpt-5-mini"
    MAX_HISTORY_MESSAGES = 12
    MAX_RESPONSE_CALLS = 3
    MAX_TOOL_CALLS = 5
    FAILURE_MESSAGE = "I couldn't reach the librarian right now. Please try again in a moment."
    LIMIT_MESSAGE = "I needed too many catalog lookups to answer that. Try narrowing the question."

    Result = Struct.new(:messages, :assistant_message, :failed, keyword_init: true) do
      def failed?
        failed
      end
    end

    def initialize(client: OpenAi::ClientFactory.current, catalog_context: Librarian::CatalogContext.call, tools: Librarian::CatalogTools.new)
      @client = client
      @catalog_context = catalog_context
      @tools = tools
    end

    def call(message:, history:)
      messages = normalized_history(history)
      user_message = message.to_s.strip
      messages << { "role" => "user", "content" => user_message }

      assistant_message = complete(messages)
      messages << { "role" => "assistant", "content" => assistant_message }

      Result.new(messages: trimmed_history(messages), assistant_message: assistant_message, failed: false)
    rescue StandardError => error
      Rails.logger.warn("Librarian chat failed: #{error.class}: #{error.message}")
      messages ||= normalized_history(history)
      messages << { "role" => "user", "content" => message.to_s.strip } unless messages.last&.dig("content") == message.to_s.strip
      messages << { "role" => "assistant", "content" => FAILURE_MESSAGE }

      Result.new(messages: trimmed_history(messages), assistant_message: FAILURE_MESSAGE, failed: true)
    end

    private

    attr_reader :client, :catalog_context, :tools

    def complete(messages)
      input_items = messages.dup
      response_calls = 0
      tool_calls = 0

      while response_calls < MAX_RESPONSE_CALLS
        response = client.create_response(parameters: response_parameters(input_items))
        response_calls += 1

        function_calls = function_calls(response)
        return extracted_text(response) if function_calls.empty?

        remaining_tool_calls = MAX_TOOL_CALLS - tool_calls
        return LIMIT_MESSAGE if remaining_tool_calls <= 0

        selected_calls = function_calls.first(remaining_tool_calls)
        tool_calls += selected_calls.length
        input_items += Array(response["output"])
        input_items += selected_calls.map { |function_call| function_call_output(function_call) }
      end

      LIMIT_MESSAGE
    end

    def response_parameters(input)
      {
        model: MODEL,
        instructions: instructions,
        input: input,
        tools: Librarian::CatalogTools.definitions,
        store: false
      }
    end

    def instructions
      <<~PROMPT.strip
        You are the librarian assistant for a personal family library app.
        Answer only from the catalog data and tool results provided by this application.
        Be concise, warm, and direct. If the catalog does not contain the answer, say so.
        Use the SQL-backed tools when the user asks for filtering, counts, owners, authors, genres, or specific books.
        Do not mention internal tool names or implementation details.

        Catalog snapshot:
        #{catalog_context}
      PROMPT
    end

    def function_calls(response)
      Array(response["output"]).select { |item| item["type"] == "function_call" }
    end

    def function_call_output(function_call)
      result = tools.call(function_call["name"], parsed_arguments(function_call))
      {
        "type" => "function_call_output",
        "call_id" => function_call["call_id"],
        "output" => JSON.generate(result)
      }
    rescue StandardError => error
      {
        "type" => "function_call_output",
        "call_id" => function_call["call_id"],
        "output" => JSON.generate({ "error" => error.message })
      }
    end

    def parsed_arguments(function_call)
      JSON.parse(function_call["arguments"].presence || "{}")
    rescue JSON::ParserError
      {}
    end

    def extracted_text(response)
      text = OpenAi::ResponseText.extract(response).to_s.strip
      text.presence || "I could not find an answer in the library catalog."
    end

    def normalized_history(history)
      Array(history).filter_map do |message|
        role = value_for(message, "role")
        content = value_for(message, "content").to_s.strip
        next unless %w[user assistant].include?(role)
        next if content.blank?

        { "role" => role, "content" => content }
      end.last(MAX_HISTORY_MESSAGES)
    end

    def trimmed_history(messages)
      messages.last(MAX_HISTORY_MESSAGES)
    end

    def value_for(hash, key)
      return unless hash.respond_to?(:[])

      hash[key] || hash[key.to_sym]
    end
  end
end
