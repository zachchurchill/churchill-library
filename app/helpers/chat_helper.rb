module ChatHelper
  # Special error for when messages added out of order
  class MessageOrderError < StandardError
    attr_reader :message

    def initialize(message = nil)
      super(message)
      @message = message
    end
  end

  # Tracks the messages between the user & assistant in a conversation
  class Conversation
    attr_reader :messages

    def initialize
      @messages = []
    end

    def add_user_message(content)
      unless @messages.empty? || @messages.last[:role] == "assistant"
        raise ChatHelper::MessageOrderError, "expecting assistant message"
      end

      @messages.push({ role: "user", content: content })
    end

    def add_assistant_message(content)
      unless @messages.empty? || @messages.last[:role] == "user"
        raise ChatHelper::MessageOrderError, "expecting user message"
      end

      @messages.push({ role: "assistant", content: content })
    end
  end
end
