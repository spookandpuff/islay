module Islay
  module Admin
    class AssetLibraryController < ApplicationController
      header 'Asset Library'
      nav 'nav'

      def index
        @groups         = AssetGroup.summary.top_level.order('name')
        @latest_assets  = Asset.limit(11).order("updated_at DESC")
        @asset_tags     = AssetTag.order('name')
      end

      def browser
        @albums = AssetAlbum.of(params[:only]).order('name ASC')
        @assets = Asset.summaries.of(params[:only])
        render :layout => false
      end
    end
  end
end
