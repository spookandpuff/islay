module Islay
  class Extensions
    attr_reader :entries

    def initialize
      @entries = {}
      @config_cache = {}
    end

    def register
      ext = Entry.new
      yield(ext)
      @entries[ext.config[:namespace]] = ext
    end

    def roots
      @roots ||= engines.map(&:root)
    end

    def engines
      @engines ||= entries.map {|n, e| e.config[:engine]}
    end

    def each(config = nil, &blk)
      if config
        (@config_cache[config] ||= @entries.map {|n, e| e.config[config]}.flatten).each(&blk)
      else
        @entries.each(&blk)
      end
    end
  end

  class Entry
    attr_reader :config

    def initialize
      @config = {
        :add_item_entries   => [],
        :reports_entries    => [],
        :admin_scripts      => false,
        :admin_styles       => false,
        :public_styles      => false,
        :dashboard          => [],
        :reports_dashboard  => []
      }
    end

    # Defines an entry in the add items collection. These are links that are 
    # rendered in the Add Item dialog.
    #
    # @param String title
    # @param Symbol route
    # @param String icon
    # @return nil
    def add_item_entry(title, route, icon)
      @config[:add_item_entries] << {:title => title, :route => route, :icon => icon}
      nil
    end

    # Specifies a cell and the position it should be displayed within the
    # dashboard.
    #
    # @param String col
    # @param String pos
    # @param String name
    #
    # @return Hash
    def dashboard(col, pos, name)
      @config[:dashboard] << {:col => col, :pos => pos, :name => name}
    end

    # Specifies a cell and the position it should be displayed within the
    # reports dashboard.
    #
    # @param Symbol col
    # @param Symbol pos
    # @param Symbol name
    #
    # @return Hash
    def report_dashboard(col, pos, name)
      @config[:reports_dashboard] << {:col => col, :pos => pos, :name => name}
    end

    # Adds the specified route to the list of those to be included in the
    # reporting section.
    #
    # @param String title
    # @param Symbol route
    # @param Hash opts
    #
    # @return Hash
    def reports(title, route, opts = {})
      @config[:reports_entries] << {:title => title, :route => route, :opts => opts}
    end

    def admin_scripts(flag)
      @config[:admin_scripts] = flag
    end

    def admin_scripts?
      @config[:admin_scripts]
    end

    def admin_styles(flag)
      @config[:admin_styles] = flag
    end

    def public_styles(flag)
      @config[:public_styles] = flag
    end

    def admin_styles?
      @config[:admin_styles]
    end

    def public_styles?
      @config[:public_styles]
    end

    # Indicates if this extension refers to a Rails engine.
    #
    # @return [true, false]
    def is_engine?
      !!@config[:engine]
    end

    # Indicates if this extension refers to a Rails application.
    #
    # @return [true, false]
    def is_app?
      !!@config[:app]
    end

    # Declare the namespace for the extension. This is a Symbol that should 
    # resolve to a module. 
    #
    # @param Symbol v
    # @return nil
    def namespace(v)
      @config[:namespace] = v
      mod = @config[:module] = v.to_s.classify.constantize

      if mod.const_defined?(:Engine)
        @config[:engine] = mod.const_get('Engine')
      elsif mod.const_defined?(:Application)
        @config[:app] = mod.const_get('Application')
      end

      nil
    end

    # Defines the configuration for the extension
    #
    # @param String name
    # @param String key
    # @param Proc blk
    
    # @return nil
    def configuration(name, key, &blk) 
      Islay::Configuration.define(name, key, &blk)
      nil
    end

    # Defines or extends a navigation section.
    #
    # @param Symbol name
    # @param Integer priority
    # @param Proc blk
    # @return nil
    def nav_section(name, priority = 2, &blk) 
      Islay::Navigation.section(name, priority, &blk)
      nil
    end
  end
end
