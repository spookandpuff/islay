module Islay
  module AdminController
    def self.included(klass)
      klass.class_eval do
        include InstanceMethods
        extend ClassMethods

        helper Islay::Helpers
        layout 'layouts/islay/application'
        before_filter :authenticate_user!, :store_user_in_thread
      end
    end

    module InstanceMethods
      private

      def store_user_in_thread
        Thread.current[:current_user] = current_user
      end
    end

    module ClassMethods

    end
  end
end
