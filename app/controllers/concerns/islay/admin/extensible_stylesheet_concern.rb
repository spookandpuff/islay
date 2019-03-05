module Islay
  module Admin
    module ExtensibleStylesheetConcern
      extend ActiveSupport::Concern

      included do
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
end
