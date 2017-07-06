module Pushr
  module Daemon
    module Apns2Support
      class ConnectionError < StandardError; end

      class Connection
        TIMEOUT = 30
        RENEW_TOKEN = 60 * 55
        attr_reader :name, :configuration

        def initialize(configuration, i)
          @name = "#{configuration.app}: Connection #{i}"
          @configuration = configuration
        end

        def connect
          @client = NetHttp2::Client.new(url, connect_timeout: TIMEOUT)
        end

        def url
          @configuration.sandbox ? 'https://api.development.push.apple.com' : 'https://api.push.apple.com'
        end

        def token
          if !@token || (Time.now - @timestamp > RENEW_TOKEN)
            @timestamp = Time.now
            @token = Token.new(configuration).generate
          end
          @token
        end

        def write(notification)
          retry_count = 0

          request = Request.new(notification, token)
          begin
            response = @client.call(:post, request.path, body: request.body, headers: request.headers,
                                                         timeout: TIMEOUT)
            puts response.inspect
            Response.new(headers: response.headers, body: response.body) if response
          rescue SocketError => e
            retry_count += 1

            if retry_count == 1
              Pushr::Daemon.logger.error("[#{name}] Lost connection to #{url} (#{e.class.name}), reconnecting...")
            end

            if retry_count <= 3
              Pushr::Daemon.logger.error("[#{name}] retrying #{retry_count}")
              # connect
              sleep 1
              retry
            end

            raise ConnectionError, "#{name} tried #{retry_count - 1} times but failed (#{e.class.name})."
          end
        end

        # def write(notification)
        #   request = Request.new(notification, token)
        #   http2_request = @client.prepare_request(:post, request.path, body: request.body, headers: request.headers)
        #   push = Push.new(http2_request)
        #   push.on(:response) do |response|
        #     # read the response
        #     puts response.ok?      # => true
        #     puts response.status   # => '200'
        #     puts response.headers  # => {":status"=>"200", "apns-id"=>"6f2cd350-bfad-4af0-a8bc-0d501e9e1799"}
        #     puts response.body     # => ""
        #   end
        #   @client.call_async(push.http2_request)
        # end

        def close
          @client.close
        end

        # def join
        #   @client.join
        # end

        def on(event, &block)
          @client.on(event, &block)
        end
      end
    end
  end
end
