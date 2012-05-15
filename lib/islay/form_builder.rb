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
      content_tag(:fieldset, output, opts)
    end

    # Proxies the input method provided by simple_form. It allows for classes
    # to be added directly to the input without using the :input_html option.
    # An additional :col option can be used to attach a class to the wrapper
    # div.
    def input(attribute_name, options = {}, &block)
      if input_class = options.delete(:class)
        (options[:input_html] ||= {}).merge!(:class => input_class)
      end

      if wrapper_class = options.delete(:col)
        (options[:wrapper_html] ||= {}).merge!(:class => wrapper_class)
      end

      super
    end
  end
end
