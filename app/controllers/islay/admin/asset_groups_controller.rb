module Islay
  module Admin
    class AssetGroupsController < ApplicationController
      resourceful :asset_group
      header 'Asset Library'
      nav 'islay/admin/asset_library/nav'

      def index
        @groups = AssetGroup.summary.top_level.order('name')
      end

      def show
        @asset_group = find_record

        case @asset_group
        when AssetCollection
          @groups = @asset_group.children.summary
          render :collection
        when AssetAlbum
          render :album
        end
      end

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
        when 'collection'
          if @asset_group.new_record?
            AssetCollection.all
          else
            AssetCollection.where("id != ?", params[:id])
          end
        when 'album'
          AssetCollection.all
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
