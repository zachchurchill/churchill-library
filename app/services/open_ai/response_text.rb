module OpenAi
  class ResponseText
    def self.extract(response)
      return response["output_text"] if response["output_text"].present?

      Array(response["output"]).filter_map do |item|
        next unless item["type"] == "message" && item["role"] == "assistant"

        Array(item["content"]).filter_map do |content|
          content["text"] if content["type"] == "output_text" || content["text"].present?
        end
      end.flatten.join("\n")
    end
  end
end
