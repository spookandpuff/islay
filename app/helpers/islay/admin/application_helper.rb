module Islay
  module Admin
    module ApplicationHelper
      def path(part)
        send(:"admin_#{part}_path")
      end

      def sub_header(heading = nil, &blk)
        content = ''.html_safe
        content << content_tag(:h1, heading) if heading
        content << capture(&blk) if block_given?

        content_tag(:div, content, :id => 'sub-header')
      end

      def content(opts = {}, &blk)
        content_tag(:div, capture(&blk), opts.merge(:id => 'content'))
      end

      def footer(opts = {}, &blk)
        content_tag(:div, capture(&blk), opts.merge(:id => 'footer'))
      end

      def body_id
        params['controller'].gsub('/', '-')
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
