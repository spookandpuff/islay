module Islay
  module Admin
    module ApplicationHelper
      # A shortcut for generating routes namespaced to the Admin module.
      def path(*args)
        first, second = args[0], args[1]

        if first.is_a?(ActiveRecord::Base)
          url_for([:admin, first])
        elsif first.is_a?(Symbol)
          if second.is_a?(ActiveRecord::Base)
            url_for([first, :admin, second])
          else
            url_for([:admin, first])
          end
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
      #   sub_header('Welcome') # => '<div id="sub-header"><h1>Welcome</h1></div>'
      #
      # Alternatively, it can be passed a block containing markup, which will
      # then be injected into the heading container.
      def sub_header(heading = nil, suffix = nil, &blk)
        content = ''.html_safe

        if heading
          heading << " -  #{suffix}" if suffix
          content << content_tag(:h1, heading)
        end

        if block_given?
          content << capture(&blk)
        end

        content_tag(:div, content, :id => 'sub-header')
      end

      # This method is used to capture the main content for a page and wrap it
      # in a containing element.
      def content(opts = {}, &blk)
        content_tag(:div, capture(&blk), opts.merge(:id => 'content'))
      end

      # Places the contents of a block in a div positioned at the bottom of the
      # screen.
      def footer(opts = {}, &blk)
        content_tag(:div, capture(&blk), opts.merge(:id => 'footer'))
      end

      # Used to attach an ID to the body of the layout. This is then used as a
      # hook for attaching Javascript initializers to specific pages.
      def body_id
        params['controller'].gsub('/', '-')
      end

      # Works in conjunction with #body_id to provide hooks for Javascript
      # initializers. For example an event could be attached to a specific
      # controller/action using a selector like this:
      #
      #   '#islay-admin-dashboard.index'
      #
      def body_class
        if @footer
          "#{params['action']} has-footer"
        else
          params['action']
        end
      end
    end
  end
end