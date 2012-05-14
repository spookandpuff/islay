module Islay
  module AdminController
    def self.included(klass)
      klass.class_eval do
        include InstanceMethods
        extend ClassMethods

        # Add helpers
        # Install auth
        # Add any before_filters

        layout 'layouts/islay/application'
      end
    end

    module InstanceMethods

    end

    module ClassMethods

    end
  end
end
