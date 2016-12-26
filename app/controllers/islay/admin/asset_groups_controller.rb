module Islay
  module Admin
    class AssetGroupsController < ApplicationController
      resourceful :asset_group
      header 'Asset Library - Collections'
      nav_scope :asset_library

      def index
        @groups = AssetGroup.summary.order('name')
      end

      private

      def dependencies
        @asset_groups = AssetGroup.all
      end
    end
  end
end
