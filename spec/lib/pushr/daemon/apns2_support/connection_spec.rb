require 'spec_helper'
require 'pushr/configuration_apns2'
require 'pushr/message_apns2'
require 'pushr/daemon'
require 'pushr/daemon/apns2'
require 'pushr/daemon/apns2_support/connection'

describe Pushr::Daemon::Apns2Support::Connection do
  before(:each) do
    Pushr::Core.configure do |config|
      config.redis = ConnectionPool.new(size: 1, timeout: 1) { MockRedis.new }
    end
  end

  let(:config) do
    Pushr::ConfigurationApns.new(app: 'app_name', connections: 2, enabled: true)
  end
  let(:message) do
    hsh = { app: 'app_name', device: 'a' * 64,  alert: 'message', badge: 1, sound: '1.aiff', expiry: 24 * 60 * 60,
            attributes_for_device: { key: 'test' }, priority: 10 }
    Pushr::MessageApns2.new(hsh)
  end
  let(:connection) { Pushr::Daemon::Apns2Support::Connection.new(config, 1) }

  describe 'sends a message' do
    it 'succesful'
  end
end
