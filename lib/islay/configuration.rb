module Islay
  # This module handles defining the site level configuration
  # A configuration is defined by an array of hashes with the following keys:
  #
  # key:      The machine key for this config (usually the engine or extension name)
  # name:     The display name for the config
  # group:    A group name, for organising configs within a definition
  # type:     One of: Boolean, Text, Enum, Date, Integer, Float, Money
  # limit:    A length limit for the value
  # hint:     Used when displaying the config UI
  # default:  The default value
  # values:   An array of possible values, used with the enum type
  # 
  # For example:
  # {
  #   key:    'notify_email',
  #   name:   'Shop notification email',
  #   group:  :notifications,
  #   type:   :string,
  #   limit:  255,
  #   hint:   'This address will receive notifications about new orders and other shop related updates.' 
  # }
  module Configuration
    # Define a configuration structure for the site
    #
    # @param String name
    # @param String key
    # @param Proc blk
    # @return nil
    def self.define(name, key, &blk)
      if ActiveRecord::Base.connection.tables.include?('site_configs')
        @config = SiteConfig.find_or_initialize_by(name: name, key: key)
        blk.call(self)
        nil
      end
    end

    def self.enum(name, opts = {})
      @config.send(:define_enum, name, opts)
    end

    def self.string(name, opts = {})
      @config.send(:define_string, name, opts)
    end

    def self.text(name, opts = {})
      @config.send(:define_string, name, opts)
    end

    def self.boolean(name, opts = {})
      @config.send(:define_boolean, name, opts)
    end

    def self.date(name, opts = {})
      @config.send(:define_date, name, opts)
    end

    def self.integer(name, opts = {})
      @config.send(:define_integer, name, opts)
    end

    def self.float(name, opts = {})
      @config.send(:define_float, name, opts)
    end

  end
end
