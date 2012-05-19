module Islay
  module Admin
    class AssetLibraryController < ApplicationController
      header 'Asset Library'

      def index
        @asset_groups = AssetGroup.roots
      end
    end
  end
end
