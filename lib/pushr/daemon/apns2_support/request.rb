module Pushr
  module Daemon
    module Apns2Support
      class Request
        attr_reader :path, :headers, :body

        def initialize(notification, token)
          @path = "/3/device/#{notification.token}"
          @headers = build_headers_for(notification, token)
          @body = notification.body
        end

        private

        def build_headers_for(notification, token)
          h = {}
          h['authorization'] = "bearer #{token}"
          h['apns-id'] = notification.apns_id if notification.apns_id
          h['apns-collapse-id'] = notification.apns_collapse_id if notification.apns_collapse_id
          h['apns-expiration'] = notification.apns_expiration if notification.apns_expiration
          h['apns-priority'] = notification.apns_priority if notification.apns_priority
          h['apns-topic'] = notification.apns_topic if notification.apns_topic
          h
        end
      end
    end
  end
end
