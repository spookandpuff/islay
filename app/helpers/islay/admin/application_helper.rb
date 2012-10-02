module Islay
  module Admin
    module ApplicationHelper
      include ::Islay::ApplicationHelper

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

        case object
        when Symbol, Array
          form_for(object, *(args << options), &block)
        else
          form_for([:admin, object], *(args << options), &block)
        end
      end

      # Shortcut for rendering the asset_picker partial, while giving it access
      # to an instance of a form builder.
      #
      # @param FormBuilder f
      #
      # @return String
      def asset_picker(f)
        render :partial => 'islay/admin/shared/asset_picker', :locals => {:f => f}
      end

      # Creates markup for displaying an update time and the name of the user
      # who updated the record.
      #
      # @param ActiveRecord::Base model
      #
      # @return string
      def update_time(model)
        tag = content_tag(:span, model.updated_at, :class => 'time', :title => model.updated_at)
        tag + " by #{model[:updater_name] || model.updater.name}"
      end

      # Creates markup for displaying an creation time and the name of the user
      # who created the record.
      #
      # @param ActiveRecord::Base model
      #
      # @return string
      def creation_time(model)
        tag = content_tag(:span, model.created_at, :class => 'time', :title => model.created_at)
        (tag + " by #{model[:creator_name] || model.creator.name}").html_safe
      end

      # Creates a span element classed to display a tick or cross depending on
      # the value of the boolean it's given.
      #
      # @param Boolean bool
      #
      # @return String
      def boolean_indicator(bool)
        content_tag(
          :span,
          content_tag(:span, friendly_bool(bool)),
          :class => "boolean #{bool}"
        )
      end

      # Converts a boolean value into a friendlier yes or no.
      #
      # @param Boolean bool
      #
      # @return String
      def friendly_bool(bool)
        bool ? "Yes" : "No"
      end

      # Takes a number and turns it into money string with two decimal places.
      #
      # @param [String, Integer, Float] value
      #
      # @return String
      def format_money(value)
        case value
        when nil then '$0.00'
        else "$%.2f" % value
        end
      end

      # Takes a string or a date and returns a string with three letter month
      # and year with century.
      #
      # @param [Time, String] time
      #
      # @param String
      def format_month(time)
        case time
        when String   then time.to_time.strftime('%b %Y')
        when Time     then time.strftime('%b %Y')
        when nil, ''  then '-- ----'
        end
      end

      # Takes a string or a date and returns a string with the day,
      # three letter month and year with century.
      #
      # @param [Time, String] time
      #
      # @param String
      def format_day(time)
        case time
        when String then time.to_time
        when Time   then time
        end.strftime('%-d %b %Y')
      end

      # Convenience helper for writing out a div column with the specified width.
      # Can optionally be given an id or extra classes. It's also possible to
      # change the element generated using the :el option.
      def column(count, opts = {}, &blk)
        opts[:class] = opts[:class] ? "column count-#{count} #{opts[:class]}" : "column count-#{count}"
        content_tag(opts.delete(:el) || :div, capture(&blk), opts)
      end

      # Adds an entry into the sub header navigation, which is used to create breadcrumbs or headings
      #
      # @param content string
      #
      # @return Array
      def sub_header(text, link = nil)
        @sub_header_entries ||= []


        @sub_header_entries <<  if link
          link_to(text, link)
        else
          text
        end
      end

      def prefixed_sub_header(prefix, text, link = nil)
        @sub_header_entries ||= []

        @sub_header_entries << if link
          link_to("#{content_tag(:strong, prefix)} #{text}", link)
        else
          "#{content_tag(:strong, prefix)} #{text}".html_safe
        end
      end

      # Indicates if there is a sub-header defined.
      #
      # @return Boolean
      def sub_header?
        !!@sub_header_entries
      end

      def output_sub_header
        if @sub_header_entries.count > 1
          crumb_items = @sub_header_entries.map do |c|
            content_tag(:li, c)
          end.join

          content_tag(:ol, crumb_items.html_safe, :class => 'breadcrumb')
        else
          content_tag(:h2, *@sub_header_entries)
        end
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


      # Provides control over the 'folding' behaviour of the filter nav. By
      # default it only displays the current selection, but in some cases we
      # need all of them shown.
      #
      # @param Boolean bool
      #
      # @return Boolean
      def fold_filter_nav(bool)
        @fold_filter_nav = bool
      end

      # Checks to see if the filter nav should be folded away. By default this
      # is true. It can be overridden with #fold_filter_nav
      #
      # @return Boolean
      def fold_filter_nav?
        if defined? @fold_filter_nav
          @fold_filter_nav
        else
          true
        end
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
          url = path(:filter_and_sort, route, :filter => by, :sort => params[:sort], :page => params[:page])
          if request.original_url.match(%r{^#{url}})
            @filter_nav[:current] = url
            @filter_nav[:entries] << [name, url, true]
          else
            @filter_nav[:entries] << [name, url]
          end
        else
          url = path(:filter_and_sort, route, :filter => nil, :sort => params[:sort], :page => params[:page])
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
          url = path(:filter_and_sort, route, :sort => by, :filter => params[:filter], :page => params[:page])
          if request.original_url.match(%r{^#{url}})
            @sort_nav[:current] = url
            @sort_nav[:entries] << [name, url, true]
          else
            @sort_nav[:entries] << [name, url]
          end
        else
          url = path(:filter_and_sort, route, :sort => nil, :filter => params[:filter], :page => params[:page])
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

      # Indicates if the filter or sorting nav should be displayed.
      #
      # @return Boolean
      def filter_or_sort_nav?
        sort_nav? or filter_nav?
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
      #
      # The content wrapper will be suppressed for AJAX requests.
      #
      # @param Hash opts
      # @param Proc blk
      #
      # @return String
      def content(opts = {}, &blk)
        output = capture(&blk)
        if request.xhr?
          output
        else
          content_tag(:div, output, opts.merge(:id => 'content'))
        end
      end

      # Places the contents of a block in a div positioned at the bottom of the
      # screen.
      #
      # The contents of the footer will be supressed in AJAX requests.
      #
      # @param Hash opts
      # @param Block
      #
      # @return [String, nil]
      def footer(opts = {}, &blk)
        unless request.xhr?
          @has_footer = true
          content_tag(:div, capture(&blk), opts.merge(:id => 'footer'))
        end
      end

      # Creates an edit button for a record.
      #
      # @param ActiveRecord::Base record
      #
      # @return String
      def edit_button(record)
        link_to('Edit', path(:edit, record), :class => 'button edit')
      end

      # Creates an cancel button for a record. Default route will point to the
      # show action for the record.
      #
      # @param ActiveRecord::Base record
      #
      # @return String
      def cancel_button(record, p = nil)
        link_to('Cancel', p || path(record), :class => 'button cancel')
      end

      # Creates a delete button for a record.
      #
      # @param ActiveRecord::Base record
      #
      # @return String
      def delete_button(record)
        link_to('Delete', path(:delete, record), :title => 'Confirm Deletion', :class => 'button delete')
      end

      # Creates a save button for a record. To be used within a form.
      #
      # @param String text
      #
      # @return String
      def save_button(text = 'Save')
        content_tag(:button, text, :class => 'save', :name => 'save')
      end

      # Creates a new button for a record.
      #
      # @param String text link text
      # @param Symbol resource the new resource to create
      # @param Hash opts options passed to the url generator
      #
      # @return String
      def new_button(text, *args)
        link_to(text, path(:new, *args), :class => 'button new')
      end

      # Creates a set of buttons to be used when moving selections within a list
      # up or down in position.
      #
      # @return String
      def position_buttons

        button_content = content_tag(:label, 'Move selection') +
        content_tag(:button, content_tag(:span, 'Down'), :name => 'do', :value => 'move_down', :class => 'move-down') +
        content_tag(:button, content_tag(:span, 'Up'), :name => 'do', :value => 'move_up', :class => 'move-up')

        content_tag(:fieldset, button_content, :class => 'position-controls')
      end

      # Checks to see if a record with this ID has been selected.
      #
      # @param Integer id
      #
      # @return Boolean
      def selected?(id)
        !ids.empty? and ids.include?(id)
      end

      # Returns a list of ids stored in the flash, coerced to ints.
      #
      # @return Array<Integer>
      def ids
        @ids ||= (flash[:ids] ? flash[:ids].map(&:to_i) : [])
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
        output << ' has-sub-header' if sub_header?

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
