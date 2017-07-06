require 'spec_helper'
require 'pushr/message_apns2'

describe Pushr::MessageApns2 do

  before(:each) do
    Pushr::Core.configure do |config|
      config.redis = ConnectionPool.new(size: 1, timeout: 1) { MockRedis.new }
    end
  end

  describe 'next' do
    it 'returns next message' do
      expect(Pushr::Message.next('pushr:app_name:apns2')).to eql(nil)
    end
  end

  describe 'save' do
    let(:message) do
      hsh = { app: 'app_name', token: 'a' * 64, alert: 'message', badge: 1, sound: '1.aiff',
              expiry: 24 * 60 * 60, attributes_for_device: { key: 'test' }, priority: 10 }
      Pushr::MessageApns2.new(hsh)
    end

    it 'should return true' do
      expect(message.save).to eql true
    end
    it 'should save a message' do
      message.save
      expect(Pushr::Message.next('pushr:app_name:apns2')).to be_kind_of(Pushr::MessageApns2)
    end
    it 'should respond to body' do
      expect(message.body).to be_kind_of(String)
    end

    context 'content-available: 1' do
      context 'with no alert/badge/sound' do
        let(:message) do
          hsh = { app: 'app_name', token: 'a' * 64, apns_expiry: 24 * 60 * 60, apns_priority: priority,
                  content_available: 1 }
          Pushr::MessageApns2.new(hsh)
        end

        context 'with priority 5' do
          let(:priority) { 5 }
          it 'should have priority 5' do
            expect(message.save).to eql true
          end
        end

        context 'with priority 10' do
          let(:priority) { 10 }
          it 'should be invalid if priority 10' do
            expect(message.save).to eql false
          end
        end
      end

      context 'with alert/badge/sound' do
        let(:message) do
          hsh = { app: 'app_name', alert: 'test', token: 'a' * 64, apns_expiry: 24 * 60 * 60, apns_priority: priority,
                  content_available: 1 }
          Pushr::MessageApns2.new(hsh)
        end

        context 'with priority 5' do
          let(:priority) { 5 }
          it 'should have priority 5' do
            expect(message.save).to eql true
          end
        end

        context 'with priority 10' do
          let(:priority) { 10 }
          it 'should be valid if priority 10' do
            expect(message.save).to eql true
          end
        end
      end
    end
  end
end
