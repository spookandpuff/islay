module Islay
  module Helpers
    # A convenience helper which automatically injects the Islay::Formbuilder
    # into the options and injects an error display if necessary.
    def islay_form(object, *args, &block)
      options = args.extract_options!
      options.merge!(:builder => Islay::FormBuilder, :html => {:id => 'islay-form'})

      model = object.is_a?(Array) ? object.last : object

      if model.errors.empty?
        form_for(object, *(args << options), &block)
      else
        error = content_tag(:p, 'Could not save, there are some errors', :id => 'error-message')
        error + form_for(object, *(args << options), &block)
      end
    end
  end
end
