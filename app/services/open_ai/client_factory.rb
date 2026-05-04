module OpenAi
  class ClientFactory
    CURRENT_CLIENT_KEY = :open_ai_current_client

    class << self
      def current
        Thread.current[CURRENT_CLIENT_KEY] || RealClient.new
      end

      def current=(client)
        Thread.current[CURRENT_CLIENT_KEY] = client
      end

      def with_client(client)
        previous_client = Thread.current[CURRENT_CLIENT_KEY]
        self.current = client
        yield client
      ensure
        self.current = previous_client
      end
    end
  end
end
