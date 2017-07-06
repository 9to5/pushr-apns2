module Pushr
  module Daemon
    class Apns2
      attr_accessor :configuration, :handlers

      def initialize(options)
        @configuration = options
        @handlers = []
      end

      def start
        configuration.connections.times do |i|
          connection = Apns2Support::Connection.new(configuration, i + 1)
          connection.connect
          # connection.on(:error) do |exception|
          #   puts "Exception has been raised: #{exception}"
          #   connection.connect
          # end

          handler = MessageHandler.new("pushr:#{configuration.key}", connection, configuration.app, i + 1)
          handler.start
          @handlers << handler
        end
      end

      def stop
        @handlers.map(&:stop)
        @handlers.map { |handler| Thread.new { handler.connection.close } }
      end
    end
  end
end
