module Islay
  module AdminController
    def self.included(klass)
      klass.class_eval do
        include InstanceMethods
        extend ClassMethods

        helper Islay::Helpers
        layout 'layouts/islay/application'
        before_filter :authenticate_user!, :store_user_in_thread

        helper_method :path
      end
    end

    module InstanceMethods
      private

      def store_user_in_thread
        Thread.current[:current_user] = current_user
      end

      # A shortcut for generating routes namespaced to the Admin module.
      def path(*args)
        first, second, rest = args

        if first.is_a?(::ActiveRecord::Base)
          url_for([:admin, *args])
        elsif first.is_a?(Symbol)
          if second.is_a?(::ActiveRecord::Base) || second.is_a?(Symbol)
            url_for([first, :admin, second, *rest])
          else
            url_for([:admin, *args])
          end
        end
      end
    end

    module ClassMethods

    end
  end
end
