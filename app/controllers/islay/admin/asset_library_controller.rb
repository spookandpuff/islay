module Islay
  module Admin
    class AssetLibraryController < ApplicationController
      header 'Asset Library'

      def index
        @asset_groups = AssetGroup.where(:asset_group_id => nil).order('type DESC, name DESC')
        @latest_assets = Asset.limit(12).order("created_at DESC")
      end

      def browser
        @albums = AssetAlbum.order('name ASC')
        @assets = Asset.summaries
        render :layout => false
      end
    end
  end
end
