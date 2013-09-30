module Islay
  module Admin
    class AssetLibraryController < ApplicationController
      header 'Asset Library'
      nav_scope :asset_library

      def index
        @groups         = AssetGroup.summary.top_level.order('name')
        @latest_assets  = Asset.limit(11).order("updated_at DESC")
        @asset_tags     = AssetTag.order('name')
      end

      def browser
        @albums = AssetGroup.of(params[:only]).order('name ASC')
        @assets = Asset.summaries.of(params[:only])
        render :layout => false
      end
    end
  end
end
