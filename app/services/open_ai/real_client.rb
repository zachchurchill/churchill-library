require "openai"

module OpenAi
  class RealClient
    EMBEDDING_MODEL = "text-embedding-3-small"
    EMBEDDING_DIMENSIONS = 256

    def initialize(access_token: nil, client: nil)
      access_token ||= Rails.application.credentials.api_keys&.openai
      @client = client || OpenAI::Client.new(access_token: access_token)
    end

    def embed(content)
      embedding = @client.embeddings(
        parameters: {
          model: EMBEDDING_MODEL,
          input: content,
          dimensions: EMBEDDING_DIMENSIONS
        }
      )

      embedding.dig("data", 0, "embedding")
    end

    def create_response(parameters:)
      @client.responses.create(parameters: parameters)
    end
  end
end
