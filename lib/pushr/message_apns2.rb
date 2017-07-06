module Pushr
  class MessageApns2 < Pushr::Message
    POSTFIX = 'apns2'

    attr_accessor :token, :alert, :badge, :sound, :category, :content_available, :mutable_content, :url_args, :apns_id,
                  :apns_expiration, :apns_priority, :apns_topic, :apns_collapse_id, :custom_payload

    validate :priority_with_content_available

    def apns_id
      @apns_id ||= SecureRandom.uuid
    end

    def body
      JSON.dump(to_message).force_encoding(Encoding::BINARY)
    end

    def to_hash
      hsh = { type: self.class.to_s, app: app, token: token, alert: alert, badge: badge, sound: sound,
              category: category, content_available: content_available, mutable_content: mutable_content,
              url_args: url_args, apns_id: apns_id, apns_expiration: apns_expiration, apns_priority: apns_priority,
              apns_topic: apns_topic, apns_collapse_id: apns_collapse_id, custom_payload: custom_payload }
      hsh[Pushr::Core.external_id_tag] = external_id if external_id
      hsh
    end

    private

    def to_message
      aps = {}
      aps[:alert] = alert if alert
      aps[:badge] = badge if badge
      aps[:sound] = sound if sound
      aps[:category] = category if category
      aps['content-available'] = content_available if content_available
      aps['url-args'] = url_args if url_args
      aps['mutable-content'] = mutable_content if mutable_content

      n = { aps: aps }
      n.merge!(custom_payload) if custom_payload
      n
    end

    def priority_with_content_available
      if content_available == 1 && apns_priority != 5 && !(alert || badge || sound)
        errors.add(:apns_priority, 'Priority should be 5 if content_available = 1 and no alert/badge/sound')
      end
    end
  end
end
