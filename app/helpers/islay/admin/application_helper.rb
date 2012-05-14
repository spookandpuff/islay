module Islay
  module Admin
    module ApplicationHelper
      def path(part)
        send(:"admin_#{part}_path")
      end

      def sub_header(heading = nil, &blk)
        @sub_header_text = heading
        @sub_header = capture(&blk) if block_given?
      end

      def footer(&blk)
        @footer = capture(&blk)
      end

      def body_class
        if @footer
          "#{params['action']} has-footer"
        else
          params['action']
        end
      end
    end
  end
end
