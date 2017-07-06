require 'spec_helper'
require 'pushr/configuration_apns2'

describe Pushr::ConfigurationApns2 do
  before(:each) do
    Pushr::Core.configure do |config|
      config.redis = ConnectionPool.new(size: 1, timeout: 1) { MockRedis.new }
    end
  end

  describe 'all' do
    it 'returns all configurations' do
      expect(Pushr::Configuration.all).to eql([])
    end
  end

  describe 'create' do
    it 'should create a configuration' do
      config = Pushr::ConfigurationApns2.new(app: 'app_name', connections: 2, enabled: true,
                                             private_key: 'BEGIN CERTIFICATE', team_id: '1', sandbox: true, key_id: '1')
      expect(config.key).to eql('app_name:apns2')
    end
  end

  describe 'save' do
    let(:config) do
      Pushr::ConfigurationApns2.new(app: 'app_name', connections: 2, enabled: true, private_key: 'BEGIN CERTIFICATE',
                                    team_id: '1', sandbox: true, key_id: '1')
    end
    it 'should save a configuration' do
      config.save
      expect(Pushr::Configuration.all.count).to eql(1)
      expect(Pushr::Configuration.all[0].class).to eql(Pushr::ConfigurationApns2)
    end
  end
end
