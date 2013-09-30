module Islay
  # This module provides some conveniences for defining navigation entires.
  # The nav is defined as top level 'sections', which have a name and a root
  # path. Then, each section can have sub_nav entries. A section can also 
  # be reopened. This allows engines to add entries to existing sections. e.g.
  # the shop can add nav entries to the reports.
  module Navigation
    @sections = {}

    # Returns the hash of sections defined.
    #
    # @return Hash
    def self.sections
      @sections
    end

    # Define or extend a section.
    #
    # @param Symbol name
    # @param Integer priority
    # @param Proc blk
    # @return nil
    def self.section(name, priority = 2, &blk)
      config = Section.new(priority).tap {|s| blk.call(s)}.config
      if @sections.has_key?(name)
        @sections[name][:sub_nav].concat(config.delete(:sub_nav))
        @sections[name].merge!(config)
      else
        @sections[name] = config
      end

      nil
    end

    # Convenience class which is used to construct the navigation DSL.
    class Section 
      # The configuration for a section.
      #
      # @attr_reader Hash
      attr_reader :config

      # Stub out a section config.
      #
      # @param Integer priority
      def initialize(priority)
        @config = {:sub_nav => [], :priority => priority}
      end

      # Defines the root path.
      #
      # @param String title
      # @param Symbol route
      # @param String icon
      # @param Hash opts
      # @return nil
      def root(title, route, icon, opts = {})
        @config.merge!(:title => title, :route => route, :icon => icon, :opts => opts)
        nil
      end

      # Defines a sub nav for a section.
      #
      # @param String title
      # @param Symbol route
      # @param Hash opts
      # @return nil
      def sub_nav(title, route, opts ={}) 
        @config[:sub_nav] << {:title => title, :route => route, :opts => opts}
      end
    end
  end
end
