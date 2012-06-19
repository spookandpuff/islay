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
      @config = {:nav_entries => []}
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
