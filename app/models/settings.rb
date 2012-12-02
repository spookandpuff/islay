# This class encapsulates settings pulled in from environment variables.
# Specifically those prefixed with IC_. It namespaces them and provides a
# method for lookup, erroring when config is missing.
class Settings
  @@config = Hash.new {|h,k| h[k] = {}}

  # Looks up the specified configuration, which was pulled in from the IC_*
  # env variables at boot.
  #
  # @param Symbol prefix namespace for the settings
  # @param Symbol setting the specific setting to look up
  #
  # @raises ConfigMissingError
  #
  # @return [String, Boolean, Integer]
  def self.for(prefix, setting)
    val = @@config[prefix][setting]
    if val
      val
    else
      raise ConfigMissingError.new(prefix, setting)
    end
  end

  # Checks to see if a setting is actually defined.
  #
  # @return Boolean
  def self.defined?(prefix, setting)
    !!@@config[prefix][setting]
  end

  # Checks to see if the variables required for S3 have been defined.
  #
  # @return Boolean
  def self.use_s3?
    !!(@@config[:islay][:aws_id] and @@config[:islay][:aws_secret])
  end

  # Checks to see if the IC_ISLAY_USE_HTTPS setting is present and if it's 
  # value is true.
  #
  # @return Boolean
  def self.use_https?
    self.defined?(:islay, :use_https) and self.for(:islay, :use_https) == true
  end

  # Pulls in the IC_ prefixed environment variables and constructs the
  # configuration hash.
  #
  # @return self
  def self.configure
    ENV.select {|name, val| name.match(/^IC_/)}.each_pair do |name, val|
      matches = name.match(/^IC_([A-Z]+)_(.+)/)
      if matches
        parsed_val = case val
          when /^[\d\.]+$/  then val.to_i
          when /true/       then true
          when /false/      then false
          else val
        end.freeze

        @@config[matches[1].downcase.to_sym][matches[2].downcase.to_sym] = parsed_val
      end
    end

    self
  end

  # This error is raised when any configuration prefixes or keys are missing.
  class ConfigMissingError < StandardError
    def initialize(prefix, setting)
      @prefix, @setting = prefix, setting
    end

    def to_s
      "There is no configuration defined for :#{@prefix}, :#{@setting}"
    end
  end
end

Settings.configure
