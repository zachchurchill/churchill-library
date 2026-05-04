module OpenAi
  class ClientFactory
    CURRENT_CLIENT_KEY = :open_ai_current_client

    class << self
      def current
        Thread.current[CURRENT_CLIENT_KEY] || @shared_client || RealClient.new
      end

      def current=(client)
        Thread.current[CURRENT_CLIENT_KEY] = client
      end

      def with_client(client, shared: false)
        previous_client = Thread.current[CURRENT_CLIENT_KEY]
        previous_shared_client = @shared_client
        shared ? @shared_client = client : self.current = client
        yield client
      ensure
        self.current = previous_client
        @shared_client = previous_shared_client
      end
    end
  end
end
