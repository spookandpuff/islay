require 'islay/form_builder/asset_select'
require 'islay/form_builder/destroy'
require 'islay/form_builder/position'
require 'islay/form_builder/date_picker'
require 'islay/form_builder/boolean_depressed'

module Islay
  # An extension of the simple_form builder.
  class FormBuilder < SimpleForm::FormBuilder
    include ActionView::Helpers::TagHelper

    # Wraps the block contents in a fieldset. Optionally it can have a legend
    # passed in as the first argument.
    def fieldset(*args, &blk)
      opts = args.extract_options!
      legend = args.first
      output = if legend.is_a?(String)
        content_tag(:legend, legend)
      else
        ''.html_safe
      end
      output << @template.capture(&blk)

      if opts[:col]
        opts[:class] = opts[:class] ? "#{opts[:class]} count-#{opts.delete(:col)}" : "count-#{opts.delete(:col)}"
      end

      content_tag(:fieldset, output, opts)
    end

    # Simple helper for rendering metadata attributes. It conditionally calls
    # the passed-in block if there is any attributes, giving it the collection
    # of attributes and their options.
    def metadata(&blk)
      blk.call(object.metadata_attributes) if object.has_metadata?
      nil # This ensures nothing gets written to the template if someone uses '=' to call this.
    end

    # Render metadata inputs, grouped based on their prefixed name
    def metadata_groups(&blk)
      if object.has_metadata?
        object._metadata.attributes.group_by{|(k,v)| k.to_s.split("_").first.humanize}
      else
        {}
      end
    end

    # Writes out inputs based on the contents of the hash contained in the
    # metadata column of a model. It inspects the options attached to an
    # attribute and renders the appropriate input.
    #
    # @return String
    #
    # @todo Support other types like URL, Email, etc.
    def metadata_input(attribute_name, incoming_opts = {}, &block)
      metaopts = object.metadata_attributes[attribute_name]
      options = incoming_opts.dup

      unless options.has_key?(:as)
        options[:as] = case metaopts[:type]
        when :enum
          metaopts[:kind] == :short ? 'radio_buttons' : 'select'
        when :foreign_key
          'select'
        when :integer, :float
          'numeric'
        when :tags
          raw_value = self.object.send(attribute_name) || []
          options[:class] = "#{options[:class]} metadata-tags"
          options[:input_html] = {:value => raw_value.join(',') } # We don't want the direct array.to_s as our form value
          'string'
        when :date
          options[:wrapper_class] = "#{options[:class]} date_picker"
          'string'
        when :text, :boolean
          metaopts[:type]
        end
      end

      if metaopts.has_key?(:values)
        options[:collection] = extract_values(metaopts[:values])
        options[:include_blank] = false if metaopts[:required] == true
      end

      input(attribute_name, options, &block)
    end

    # Proxies the input method provided by simple_form. It allows for classes
    # to be added directly to the input without using the :input_html option.
    # An additional :col option can be used to attach a class to the wrapper
    # div.
    #
    # @param Symbol attribute_name
    # @param Hash options
    #
    # @return String
    def input(attribute_name, options = {}, &block)
      if input_class = options.delete(:class)
        append_class!(options, :input_html, input_class)
      end

      if col = options.delete(:col)
        append_class!(options, :wrapper_html, "count-#{col}")
      end

      if wrapper_class = options.delete(:wrapper_class)
        append_class!(options, :wrapper_html, wrapper_class)
      end

      if options.delete(:first_inline)
        append_class!(options, :wrapper_html, 'first-inline')
      end

      if options.delete(:inline)
        append_class!(options, :wrapper_html, 'inline')
      end

      super
    end

    # Creates an input based on a provided hash. It inspects the options attached to an
    # attribute and renders the appropriate input. This is designed to create forms from
    # a JSON object
    #
    # @param Hash input
    # @return String
    #
    # @todo Support other types like URL, Email, etc.
    def json_input(name, opts, &block)
      options = opts.dup

      unless options.has_key?(:as)
        options[:as] = case options[:type]
        when :enum
          options[:input_type] == :short ? 'radio_buttons' : 'select'
        when :integer, :float
          'numeric'
        when :date
          options[:wrapper_class] = "#{options[:class]} date_picker"
          'string'
        when "String", "Text"
          'string'
        when "Boolean"
          'boolean'
        end
      end

      if options.has_key?(:values)
        options[:collection] = extract_values(options[:values])
        options[:include_blank] = false if options[:required] == true
      end

      input(name, options, &block)
    end

    private

    # Appends a class within the specified scope i.e. the input wrapper div, or
    # the input itself.
    #
    # @param Hash options
    # @param Symbol scope
    # @param String value
    #
    # @return nil
    def append_class!(options, scope, value)
      html = (options[scope] ||= {})

      if html[:class]
        html[:class] << " #{value}"
      else
        html[:class] = value
      end

      nil
    end

    def extract_values(values)
      if values
        case values
        when Proc         then values.call
        when Array, Hash  then values.dup
        end
      end
    end
  end # FormBuilder
end # Islay
