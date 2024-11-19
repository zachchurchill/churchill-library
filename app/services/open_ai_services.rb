require "openai"

# OpenAI services for LLM-related actions like embedding and chat completion
class OpenAiServices
  attr_reader :client

  def initialize
    @client = OpenAI::Client.new(access_token: Rails.application.credentials.api_keys.openai)
  end

  def embed(content)
    embedding = @client.embeddings(
      parameters: {
        model: "text-embedding-3-small",
        input: content,
        dimensions: 256
      }
    )
    embedding.dig("data", 0, "embedding")
  end

  def chat(conversation)
    system_prompt = <<~PROMPT.strip
      You are an assistant for a personal library collection app.
      This application catalogues the books for various owners where the title, author and genres are saved.
      Users may have queries around what kind of books the owners of these collections own and would be interested in.
      Be helpful, concise and sincere.
    PROMPT
    resp = @client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [{ role: "system", content: system_prompt }, *conversation.messages],
        temperature: 0.6
      }
    )
    conversation.add_assistant_message(resp.dig("choices", 0, "message", "content"))
  end
end
