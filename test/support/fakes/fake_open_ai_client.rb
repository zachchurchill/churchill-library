class FakeOpenAiClient
  attr_reader :calls, :embedding_calls, :response_calls

  def initialize(embeddings: [], responses: [])
    @embedding_queue = embeddings.dup
    @response_queue = responses.dup
    @calls = []
    @embedding_calls = []
    @response_calls = []
  end

  def queue_embedding(embedding)
    @embedding_queue << embedding
    self
  end

  def queue_response(response)
    @response_queue << response
    self
  end

  def embed(content)
    @embedding_calls << content
    @calls << { method: :embed, content: content }

    raise "No fake OpenAI embedding queued" if @embedding_queue.empty?

    @embedding_queue.shift
  end

  def create_response(parameters:)
    @response_calls << parameters
    @calls << { method: :create_response, parameters: parameters }

    raise "No fake OpenAI response queued" if @response_queue.empty?

    @response_queue.shift
  end
end
