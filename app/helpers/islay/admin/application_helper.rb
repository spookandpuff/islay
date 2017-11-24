module Islay
  module Admin
    module ApplicationHelper
      include ::Islay::ApplicationHelper
      include ::Islay::Admin::HeaderHelper

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

      # Conditionally renders an error notice if the supplied object is
      # invalid. Leans on a partial for the notice itself.
      #
      # @param ActiveRecord::Base object
      # @return [nil, String]
      def form_errors(object)
        unless object.errors.empty?
          render :partial => 'islay/admin/shared/form_errors'
        end
      end

      # A helper for rendering a notification within a form. This is intended
      # to be displayed at the bottom of forms and contain information about
      # the deletion or disabling of a record.
      #
      # @param Symbol kind
      # @param Proc blk
      # @return String
      def form_notice(kind, &blk)
        content = content_tag(:i, nil, :class => 'icon fa fa-exclamation') + capture(&blk)
        content_tag(:div, content.html_safe, :class => "islay-form-notice #{kind}")
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
        tag += " by #{model[:updater_name] || model.updater.name}" if model[:updater_name]
        tag
      end

      # Creates markup for displaying an creation time and the name of the user
      # who created the record.
      #
      # @param ActiveRecord::Base model
      #
      # @return string
      def creation_time(model)
        tag = content_tag(:span, model.created_at, :class => 'time', :title => model.created_at)
        (tag + " by #{model[:creator_name] || model.creator.name}") if model[:creator_name]
        tag.html_safe
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
        when String   then time.to_time.strftime('%-d %b %Y')
        when Time     then time.strftime('%-d %b %Y')
        when nil, ''  then '-- -- ----'
        end
      end

      # Convenience helper for writing out a div column with the specified width.
      # Can optionally be given an id or extra classes. It's also possible to
      # change the element generated using the :el option.
      def column(count, opts = {}, &blk)
        opts[:class] = opts[:class] ? "column count-#{count} #{opts[:class]}" : "column count-#{count}"
        content_tag(opts.delete(:el) || :div, capture(&blk), opts)
      end

      # Renders a partial which creates a nicely styled header. Intended to be
      # used on record overviews and forms.
      #
      # @param String name
      # @param String icon
      # @param Hash opts
      # @option opts String :when_blank
      # @return String
      def record_name(name, icon, opts = {})
        _name = name.blank? ? opts[:when_blank] : name
        render(
          :partial => 'islay/admin/shared/record_name',
          :locals => {:name => _name, :icon => icon}
        )
      end


      # Renders a partial which includes some introductory info about the current view
      #
      # @param String text
      # @param Hash opts
      # @return String
      def intro_text(text, opts = {})
        render(
          :partial => 'islay/admin/shared/intro_text',
          :locals => {:text => text, :opts => opts}
        )
      end

      # Adds and entry to the main navigation bar. It will additionally highlight
      # the current entry.
      #
      # @param Symbol name
      # @param String icon
      # @param Symbol path_name
      # @param Hash opts
      # @return String
      def main_nav(name, icon, path_name, opts = {})
        id ||= name.parameterize('-')
        url = path(path_name)
        root = opts.delete(:root)

        opts[:class] = if (root and request.original_url == url) or (!root and request.original_url.match(%r{^#{url}}))
          "entry current"
        else
          "entry"
        end

        content = [
          content_tag(:i, '', :class => "fa fa-#{icon}"),
          content_tag(:strong, name)
        ].join('').html_safe

        content_tag(:li, link_to(content, url, opts))
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

      # Indicates if any sub-nav entries have been defined.
      #
      # @return Boolean
      def sub_nav?
        section = Islay::Engine.nav_entries[nav_scope]
        section and !section[:sub_nav].empty?
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

      # Conditionally renders the sub navigation for the specified nav scope.
      # The nav scope is defined on each controller using the ::nav_scope
      # declaration.
      #
      # @return [String, nil]
      def render_sub_nav
        if sub_nav?
          entries = Islay::Engine.nav_entries[nav_scope][:sub_nav].map do |s|
            url = path(s[:route])
            if current_entry?(url, s[:opts][:root])
              s.merge(:url => url, :current => true)
            else
              s.merge(:url => url)
            end
          end

          render(
            :partial => 'islay/admin/shared/sub_nav',
            :locals => {:entries => entries}
          )
        end
      end

      # Checks to see if the specified URL matches the original requested URL.
      # This is a utility method for generating navigation entries and the
      # like.
      #
      # @param String url
      # @param [nil, true, false] root
      # @return [true, false]
      def current_entry?(url, root)
        (root and request.original_url == url) or (!root and request.original_url.match(%r{^#{url}}))
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
        link_to("New #{text}", path(:new, *args), :class => 'button new')
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

        output
      end

      # Writes out navigation entries specified by engines which are extending the
      # core engine.
      #
      # TODO: Memoize this in production.
      def extension_nav_entries
        Islay::Engine.nav_entries.map do |name, e|
          main_nav(e[:title], e[:icon], e[:route], e[:opts].dup)
        end.flatten.join.html_safe
      end

      # Set simple_format to actually render markdown
      #
      # @param String text
      # @return String
      def simple_format(text)
        render_markdown text
      end
    end # AdminHelpers
  end # Admin
end # Islay
