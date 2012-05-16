module Islay
  module Helpers
    # A convenience helper which automatically injects the Islay::Formbuilder
    # into the options and injects an error display if necessary.
    def resource_form(object, url, *args, &block)
      options = args.extract_options!
      options.merge!(
        :url      => url,
        :builder  => Islay::FormBuilder,
        :html   => {:id => 'islay-form'}
      )

      form_for(object, *(args << options), &block)
    end
  end
end
