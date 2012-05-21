module Islay
  class Extensions
    attr_reader :entries

    def register
      ext = Entry.new
      yield(ext)
      @entries ||= {}
      @entries[ext.config[:namespace]] = ext
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
    end

    def nav_entry(title, route)
      @config[:nav_entries] << {:title => title, :route => route}
    end
  end
end
