module Islay
  module Admin
    class AssetGroupsController < ApplicationController
      resourceful :asset_group
      header 'Asset Library'

      def new
        new_group
        dependencies
      end

      def create
        new_group
        persist!(@asset_group)
      end

      private

      def dependencies
        @asset_collections = case params[:type]
        when 'collection' then AssetCollection.where("id != ?", params[:id])
        when 'album'      then AssetCollection.all
        end
      end

      def redirect_for(model)
        case model
        when AssetCollection then path(:asset_library)
        when AssetAlbum then path(model)
        end
      end

      def new_group
        @asset_group = case params[:type]
        when 'collection' then AssetCollection.new
        when 'album'      then AssetAlbum.new
        end
      end
    end
  end
end
