module Islay
  module Admin
    class PasswordsController < Devise::PasswordsController
      layout 'islay/login'

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
