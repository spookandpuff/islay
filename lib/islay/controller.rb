module Islay
  module AdminController
    def self.included(klass)
      klass.class_eval do
        include InstanceMethods
        extend ClassMethods

        helper Islay::Helpers
        layout 'layouts/islay/application'
        before_filter :authenticate_user!
      end
    end

    module InstanceMethods

    end

    module ClassMethods

    end
  end
end
