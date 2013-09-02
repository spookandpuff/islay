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
        :nav_entries        => [],
        :reports_entries    => [],
        :admin_scripts      => false,
        :admin_styles       => false,
        :public_styles      => false,
        :dashboard          => [],
        :reports_dashboard  => []
      }
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

    def namespace(v)
      @config[:namespace] = v
      @config[:module] = v.to_s.classify.constantize
      @config[:engine] = @config[:module].const_get('Engine')
    end

    # A class which wraps the configuration of Islay's navigation. It is used
    # privately and should never be directly instanced.
    class NavigationConfig
      attr_reader :sections

      def initialize
        @sections = []
      end

      def section(title, route, icon = nil, opts = {}, &blk)
        @sections << {
          :title        => title,
          :route        => route,
          :icon         => icon || 'rocket',
          :opts         => opts,
          :sub_sections => []
        }

        if block_given?
          @current = @sections.last
          blk.call(self)
        end
      end

      def sub_section(name, path)
        @current[:sub_sections] << {:name => name, :path => path}
      end
    end

    # A convenience method for defining the main navigation and it's 
    # sub-sections.
    #
    # @param Proc blk
    # @return nil
    def navigation(&blk) 
      blk.call(navigation_config)
      @config[:navigation] = navigation_config.sections

      nil
    end

    # Defines an entry for the main navigation. This remains here for backwards
    # compatibility only. It will be removed in the future.
    #
    # @param String title
    # @param Symbol route
    # @param String icon
    # @param Hash opts
    # @return nil
    # @todo Remove this method
    def nav_entry(title, route, icon = nil, opts = {})
      ActiveSupport::Deprecation.warn("#nav_entry is deprecated and may be removed from future releases. Use #navigation.", caller)
      navigation_config.section(title, route, icon, opts)
      @config[:navigation] = navigation_config.sections

      nil
    end

    private

    # Lazily constructs an instance of the navigation config and caches it in
    # the #config Hash.
    #
    # @return NavigationConfig
    def navigation_config
      @navigation_config ||= NavigationConfig.new
    end
  end
end
