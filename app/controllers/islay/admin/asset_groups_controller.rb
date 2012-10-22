module Islay
  module Admin
    class AssetGroupsController < ApplicationController
      resourceful :asset_group
      header 'Asset Library'
      nav 'islay/admin/asset_library/nav'

      def index
        @groups = AssetGroup.summary.top_level.order('name')
      end

      private

      def dependencies
        @asset_groups = AssetGroup.all
      end
    end
  end
end
