module Islay
  module Admin
    class SiteConfigsController < ApplicationController
      resourceful :site_configs
      header 'Site Settings'
      nav_scope :config

      def index
        @site_configs = SiteConfig.all
      end

      def show
      end

      private

      def redirect_for(model)
        path(:settings)
      end
    end
  end
end
