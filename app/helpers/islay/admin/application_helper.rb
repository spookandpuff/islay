module Islay
  module Admin
    module ApplicationHelper
      # Accessors used to store various bits of configuration, which are then
      # used in the main layout of the admin,
      attr_reader :sub_nav_entries, :control_entries, :sub_header_entry

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

      # Creates a class name based on the #published? method of the argument.
      #
      # @param ActiveRecord::Base obj
      #
      # @return String
      def published_class(obj)
        obj.published ? 'published icon-ok' : 'unpublished icon-cancel'
      end

      # Converts a boolean value into a friendlier yes or no.
      #
      # @param Boolean bool
      #
      # @return String
      def friendly_bool(bool)
        bool ? "Yes" : "No"
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
        header << ": #{suffix}" if suffix
        @sub_header_entry = content = ''.html_safe
        @sub_header_entry << content_tag(:h2, header) if header
        @sub_header_entry << capture(&blk) if block_given?
      end

      # Indicates if there is a sub-header defined.
      #
      # @return Boolean
      def sub_header?
        !!@sub_header_entry
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
            opts[:class] = "#{opts[:class]} current"
          else
            opts[:class] = 'current'
          end
        end

        content_tag(:li, link_to(name, url, opts))
      end

      # Indicates if the sub-bar — containing titles and filters — should be
      # displayed.
      #
      # @return Boolean
      def show_sub_bar?
        sub_header? or filter_nav? or sort_nav?
      end

      # A utility method shared between the nav methods, which handles flagging
      # a nav entry as the current.
      #
      # @param Array ivar the instance variable to append entries to
      # @param String name displayed in the link
      # @param String url href value for link
      # @param Hash opts options which are passed directly to the link_to helper
      #
      # @return Array<String>
      def add_nav_entry(ivar, name, url, opts)
        root = opts.delete(:root)

        if (root and request.original_url == url) or (!root and request.original_url.match(%r{^#{url}}))
          opts[:class] = opts[:class] ? "#{opts[:class]} current" : 'current'
        end

        ivar << link_to(name, url, opts)
      end

      # A helper method for adding navigation entried for the filter and sort
      # controls.
      #
      # @param Hash<Array> config
      #
      # @return String
      def output_nav_entries(config)
        if !config[:current] and config[:default]
          config[:default] << true
        end

        config[:entries].map do |e|
          name, url, current = e
          if current
            content_tag(:li, link_to(name, url, :class => 'current'))
          else
            content_tag(:li, link_to(name, url))
          end
        end.join.html_safe
      end

      # Adds an entry into the filter navigation, which appears below the
      # sub-navigation. Typically used to filter lists of records.
      #
      # @param Symbol route the route set to use to generate link
      # @param String name to display
      # @param String by the field to filter by
      #
      # @return Hash<Array>
      def filter_nav(route, name, by = nil)
        @filter_nav ||= {:entries => []}

        if by
          url = path(:filter_and_sort, route, :filter => by, :sort => params[:sort])
          if request.original_url.match(%r{^#{url}})
            @filter_nav[:current] = url
            @filter_nav[:entries] << [name, url, true]
          else
            @filter_nav[:entries] << [name, url]
          end
        else
          url = path(:filter_and_sort, route, :filter => nil, :sort => params[:sort])
          entry = [name, url]
          @filter_nav[:default] = entry
          @filter_nav[:entries] << entry
        end
      end

      # Indicates if any filter nav entries have been specified.
      #
      # @return Boolean
      def filter_nav?
        !!@filter_nav
      end

      # Generates a HTML safe string of the filter nav entries
      #
      # @return String
      def filter_nav_entries
        output_nav_entries(@filter_nav)
      end

      # Adds an entry into the sort navigation. This is a control which allows
      # uses to change the order in which lists of records are displayed.
      #
      # @param Symbol route the route set to use to generate link
      # @param String name to display
      # @param String by the field to sort by
      #
      # @return Hash<Array>
      def sort_nav(route, name, by = nil)
        @sort_nav ||= {:entries => []}

        if by
          url = path(:filter_and_sort, route, :sort => by, :filter => params[:filter])
          if request.original_url.match(%r{^#{url}})
            @sort_nav[:current] = url
            @sort_nav[:entries] << [name, url, true]
          else
            @sort_nav[:entries] << [name, url]
          end
        else
          url = path(:filter_and_sort, route, :sort => nil, :filter => params[:filter])
          entry = [name, url]
          @sort_nav[:default] = entry
          @sort_nav[:entries] << entry
        end
      end

      # Indicates if any sort nav entries have been specified.
      #
      # @return Boolean
      def sort_nav?
        !!@sort_nav
      end

      # Generates a HTML safe string of the sort nav entries
      #
      # @return String
      def sort_nav_entries
        output_nav_entries(@sort_nav)
      end

      # Adds an entry into the sub navigation, which will appear in the bar
      # below the main header. Works in conjunction with the #control helper
      # but not the #sub_header helper; the nav and sub header sit in the same
      # place on screen.
      #
      # @return Array<String>
      def sub_nav(name, url, opts = {})
        add_nav_entry(@sub_nav_entries ||= [], name, url, opts)
      end

      # Indicates if any sub-nav entries have been defined.
      #
      # @return Boolean
      def sub_nav?
        @sub_nav_entries and !@sub_nav_entries.empty?
      end

      # Writes a link out into the bar below the main header. Usually used in
      # conjunction with the #sub_header or #sub_nav helpers, but never both;
      # there is not enough room in the bar.
      def control(name, url, type)
        @control_entries ||= []
        @control_entries << link_to(name, url, :class => "button #{type}")
      end

      # Indicates if any section controls have been defined.
      #
      # @return Boolean
      def controls?
        @control_entries and !@control_entries.empty?
      end

      # This method is used to capture the main content for a page and wrap it
      # in a containing element.
      def content(opts = {}, &blk)
        content_tag(:div, capture(&blk), opts.merge(:id => 'content'))
      end

      # Places the contents of a block in a div positioned at the bottom of the
      # screen.
      #
      # @param Hash opts
      # @param Block
      #
      # @return String
      def footer(opts = {}, &blk)
        @has_footer = true
        content_tag(:div, capture(&blk), opts.merge(:id => 'footer'))
      end

      # Creates an edit button for a record.
      #
      # @param ActiveRecord::Base record
      #
      # @return String
      def edit_button(record)
        link_to('Edit', path(:edit, record), :class => 'button edit')
      end

      # Creates a delete button for a record.
      #
      # @param ActiveRecord::Base record
      #
      # @return String
      def delete_button(record)
        link_to('Delete', path(:delete, record), :class => 'button delete')
      end

      # Creates a new button for a record.
      #
      # @param String text link text
      # @param Symbol resource the new resource to create
      # @param Hash opts options passed to the url generator
      #
      # @return String
      def new_button(text, resource, opts = {})
        link_to(text, path(:new, resource, opts), :class => 'button new')
      end

      # Used to attach an ID to the body of the layout. This is then used as a
      # hook for attaching Javascript initializers to specific pages.
      #
      # @return String
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
        output << ' has-sub-header' if show_sub_bar?

        output
      end

      # Writes out navigation entries specified by engines which are extending the
      # core engine.
      #
      # TODO: Memoize this in production.
      def extension_nav_entries
        Islay::Engine.extensions.entries.map do |ns, ext|
          ext.config[:nav_entries].map {|e| main_nav(e[:title], e[:route], e[:opts].dup)}
        end.flatten.join.html_safe
      end
    end # AdminHelpers
  end # Admin
end # Islay
