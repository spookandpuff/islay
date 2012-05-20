module Islay
  module Admin
    class AssetLibraryController < ApplicationController
      header 'Asset Library'

      def index
        @asset_groups = AssetGroup.roots
        @latest_assets = Asset.limit(12).order("created_at DESC")
      end
    end
  end
end
