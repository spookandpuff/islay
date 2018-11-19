module Islay
  module Admin
    class SessionsController < Devise::SessionsController
      layout 'islay/login'

      def after_sign_in_path_for(user)
        admin_dashboard_path
      end

      def extension_style_sheet(path = nil)
        @extension_style_sheets ||= []
        @extension_style_sheets << path if path
        @extension_style_sheets
      end

      alias_method :extension_style_sheets, :extension_style_sheet

      helper_method :extension_style_sheets, :extension_style_sheet
    end
  end
end
