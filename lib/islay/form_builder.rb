require 'islay/form_builder/asset_select'
require 'islay/form_builder/destroy'
require 'islay/form_builder/position'
require 'islay/form_builder/date_picker'

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

    # Writes out inputs based on the contents of the hash contained in the
    # metadata column of a model. It inspects the options attached to an
    # attribute and renders the appropriate input.
    #
    # @return String
    #
    # @todo Support other types like URL, Email, etc.
    def metadata_input(attribute_name, options = {}, &block)
      metaopts = object.metadata_attributes[attribute_name]

      unless options.has_key?(:as)
        options[:as] = case metaopts[:type]
        when :enum
          metaopts[:kind] == :short ? 'radio_buttons' : 'select'
        when :foreign_key 
          'select'
        when :integer, :float
          'numeric'
        when :text, :boolean, :date
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
