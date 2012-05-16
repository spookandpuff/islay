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
      def resourceful
        inherit_resources
        custom_actions :resource => :delete
        defaults :route_prefix => 'admin'

        include AdminResourceController::InstanceMethods
        extend AdminResourceController::ClassMethods
      end
    end
  end

  module AdminResourceController
    def InstanceMethods
      def delete
        delete! do |format|

        end
      end
    end

    module ClassMethods

    end
  end
end
