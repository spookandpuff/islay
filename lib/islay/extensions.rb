module Islay
  class Extensions
    attr_reader :entries

    def initialize
      @entries = {}
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
  end

  class Entry
    attr_reader :config

    def initialize
      @config = {
        :nav_entries => [],
        :admin_scripts => false,
        :admin_styles => false,
        :public_styles => false,
        :dashboard => []
      }
    end

    def dashboard(col, pos, name)
      @config[:dashboard] << {:col => col, :pos => pos, :name => name}
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

    def nav_entry(title, route, opts = {})
      @config[:nav_entries] << {:title => title, :route => route, :opts => opts}
    end
  end
end
