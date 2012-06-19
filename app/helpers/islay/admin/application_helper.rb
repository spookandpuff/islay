module Islay
  module Admin
    module ApplicationHelper
      # A convenience helper which automatically injects the Islay::Formbuilder
      # into the options and injects an error display if necessary.
      def resource_form(object, *args, &block)
        options = args.extract_options!
        options.merge!(
          :builder  => Islay::FormBuilder,
          :html   => {:id => 'islay-form'}
        )

        if object.is_a?(Symbol)
          form_for(object, *(args << options), &block)
        else
          form_for([:admin, object], *(args << options), &block)
        end
      end

      # Convenience helper for writing out a div column with the specified width.
      # Can optionally be given an id or extra classes. It's also possible to
      # change the element generated using the :el option.
      def column(count, opts = {}, &blk)
        opts[:class] = opts[:class] ? "column count-#{count} #{opts[:class]}" : "column count-#{count}"
        content_tag(opts.delete(:el) || :div, capture(&blk), opts)
      end

      # Writes out the sub-heading bar for a section of the admin. In the simplest
      # case it can be called with just a string. It will then generate the bar
      # with a H1:
      #
      #   header('Welcome') # => '<div id="sub-header"><h1>Welcome</h1></div>'
      #
      def header(str)
        @header = str
      end

      # Writes out a sub heading bar. Can be also used as a sub navigation bar
      # by passing a block with the markup.
      def sub_header(header = nil, suffix = nil, &blk)
        @has_sub_header = true

        header << ": #{suffix}" if suffix
        @sub_header = content = ''.html_safe
        @sub_header << content_tag(:h2, header) if header
        @sub_header << capture(&blk) if block_given?
      end

      # Adds and entry to the main navigation bar. It will additionally highlight
      # the current entry.
      def main_nav(name, path_name, opts = {})
        id ||= name.parameterize('-')
        url = path(path_name)
        opts[:id] ||= "#{id}-nav"
        root = opts.delete(:root)

        if (root and request.original_url == url) or (!root and request.original_url.match(%r{^#{url}}))
          if opts[:class]
            opts[:class] << ' current'
          else
            opts[:class] = 'current'
          end
        end

        content_tag(:li, link_to(name, url, opts))
      end

      # Adds an entry into the sub navigation, which will appear in the bar
      # below the main header. Works in conjunction with the #control helper
      # but not the #sub_header helper; the nav and sub header sit in the same
      # place on screen.
      def sub_nav(name, url, opts = {})
        @has_sub_header = true
        root = opts.delete(:root)

        if (root and request.original_url == url) or (!root and request.original_url.match(%r{^#{url}}))
          opts[:class] = 'current'
        end

        @sub_nav_entries ||= []
        @sub_nav_entries << link_to(name, url, opts)
      end

      # Writes a link out into the bar below the main header. Usually used in
      # conjunction with the #sub_header or #sub_nav helpers, but never both;
      # there is not enough room in the bar.
      def control(name, url, type)
        @has_sub_header = true

        @control_entries ||= []
        @control_entries << link_to(name, url, :class => "#{type} #{type}-icon")
      end

      # This method is used to capture the main content for a page and wrap it
      # in a containing element.
      def content(opts = {}, &blk)
        content_tag(:div, capture(&blk), opts.merge(:id => 'content'))
      end

      # Places the contents of a block in a div positioned at the bottom of the
      # screen.
      def footer(opts = {}, &blk)
        @has_footer = true
        content_tag(:div, capture(&blk), opts.merge(:id => 'footer'))
      end

      # Used to attach an ID to the body of the layout. This is then used as a
      # hook for attaching Javascript initializers to specific pages.
      def body_id
        params['controller'].gsub(/[\/_]/, '-')
      end

      # Works in conjunction with #body_id to provide hooks for Javascript
      # initializers. For example an event could be attached to a specific
      # controller/action using a selector like this:
      #
      #   '#islay-admin-dashboard.index'
      #
      def body_class
        output = params['action'].dasherize
        output << ' has-footer' if @has_footer
        output << ' has-sub-header' if @has_sub_header

        output
      end

      # Writes out navigation entries specified by engines which are extending the
      # core engine.
      #
      # TODO: Memoize this in production.
      def extension_nav_entries
        Islay::Engine.extensions.entries.map do |ns, ext|
          ext.config[:nav_entries].map {|e| main_nav(e[:title], e[:route], e[:opts])}
        end.flatten.join.html_safe
      end
    end # AdminHelpers
  end # Admin
end # Islay
