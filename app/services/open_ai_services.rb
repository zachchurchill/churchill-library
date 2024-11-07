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
end
