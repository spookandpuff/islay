module Islay
  module Helpers
    # A convenience helper which automatically injects the Islay::Formbuilder
    # into the options and injects an error display if necessary.
    def resource_form(object, *args, &block)
      options = args.extract_options!
      options.merge!(
        :builder  => Islay::FormBuilder,
        :html   => {:id => 'islay-form'}
      )

      form_for([:admin, object], *(args << options), &block)
    end
  end
end
