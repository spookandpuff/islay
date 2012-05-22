module Islay
  module Admin
    class SessionsController < Devise::SessionsController
      layout 'islay/login'

      def after_sign_in_path_for(user)
        admin_dashboard_path
      end
    end
  end
end
