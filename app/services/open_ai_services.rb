# OpenAI services for LLM-related actions like embedding and chat completion
class OpenAiServices
  attr_reader :client

  def initialize(client: OpenAi::ClientFactory.current)
    @client = client
  end

  def embed(content)
    @client.embed(content)
  end

  def create_response(parameters:)
    @client.create_response(parameters: parameters)
  end

  def chat(conversation)
    system_prompt = <<~PROMPT.strip
      You are an assistant for a personal library collection app.
      This application catalogues the books for various owners where the title, author and genres are saved.
      Users may have queries around what kind of books the owners of these collections own and would be interested in.
      Be helpful, concise and sincere.
    PROMPT
    resp = create_response(
      parameters: {
        model: "gpt-4o-mini",
        input: [{ role: "system", content: system_prompt }, *conversation.messages],
        temperature: 0.6
      }
    )
    conversation.add_assistant_message(resp["output_text"] || resp.dig("choices", 0, "message", "content"))
  end
end
