module Pushr
  class ConfigurationApns2 < Pushr::Configuration
    attr_accessor :private_key, :team_id, :key_id, :sandbox
    validates :private_key, :team_id, :key_id, presence: true
    validates :sandbox, inclusion: { in: [true, false] }

    def name
      :apns2
    end

    def certificate=(value)
      if /BEGIN CERTIFICATE/.match(value)
        @certificate = value
      else
        # assume it's the path to the certificate and try to read it:
        @certificate = read_file(value)
      end
    end

    def to_hash
      { type: self.class.to_s, app: app, enabled: enabled, connections: connections, private_key: private_key,
        team_id: team_id, key_id: key_id, sandbox: sandbox }
    end

    private

    def read_file(filename)
      File.read(build_filename(filename))
    end

    def build_filename(filename)
      if Pathname.new(filename).absolute?
        filename
      elsif Pushr::Core.configuration_file
        File.join(File.dirname(Pushr::Core.configuration_file), filename)
      else
        File.join(Dir.pwd, filename)
      end
    end
  end
end
