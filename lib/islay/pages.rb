module Islay
  class Pages
    attr_reader :pages, :shares

    @@pages = {}

    # Returns the global register of pages. This is all pages keyed by slug.
    #
    # @return Hash
    def self.definitions
      @@pages
    end

    def initialize
      @pages = {}
      @shares = {}
    end

    def page(slug, name, &blk)
      @pages[slug] = Page.new(slug, name, &blk)
    end

    def shared(slug, name, &blk)
      @shares[slug] = Page.new(slug, name, &blk)
    end

    class Page
      attr_reader :slug, :name, :pages, :contents

      def initialize(slug, name, &blk)
        @slug = slug
        @name = name
        @pages = {}
        @contents = {}
        @features = false

        Islay::Pages.definitions[slug] = self

        instance_eval(&blk)
      end

      def record
        ::Page.where(:slug => slug).first
      end

      def content_summary
        @content_summary ||= @contents.map {|s, c| c[:name]}.join(', ')
      end

      def features?
        @features
      end

      def features(bool)
        @features = bool
      end

      def content(slug, name, type, opts = {})
        @contents[slug] = {:slug => slug, :name => name, :type => type}.merge(opts)
      end

      def page(slug, name, &blk)
        @pages[slug] = Page.new(slug, name, &blk)
      end
    end
  end
end
