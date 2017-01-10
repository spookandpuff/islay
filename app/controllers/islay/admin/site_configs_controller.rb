module Islay
  module Admin
    class SiteConfigsController < ApplicationController
      resourceful :site_config
      header 'Site Settings'
      nav_scope :config

      private

      def redirect_for(model)
        path(:site_configs)
      end
    end
  end
end
