module Islay
  module Admin
    module ApplicationHelper
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

      # Adds an entry into the sub navigation, which will appear in the bar
      # below the main header. Works in conjunction with the #control helper
      # but not the #sub_header helper; the nav and sub header sit in the same
      # place on screen.
      def sub_nav(name, url, opts = {})
        @has_sub_header = true

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
    end
  end
end
