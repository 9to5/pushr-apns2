module Pushr
  module Daemon
    module Apns2Support
      class Token
        ALGORITHM = 'ES256'

        def initialize(configuration)
          @configuration = configuration
        end

        def generate
          JWT.encode(payload, ec_key, ALGORITHM, header_fields)
        end

        private

        def ec_key
          OpenSSL::PKey::EC.new(@configuration.private_key)
        end

        def payload
          { iss: @configuration.team_id, iat: Time.now.to_i }
        end

        def header_fields
          { kid: @configuration.key_id }
        end
      end
    end
  end
end
