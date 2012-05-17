module Islay
  module Admin
    class AssetsController < ApplicationController
      resourceful :asset
      header 'Asset Library'

      before_filter :find_category, :only => [:new, :create]

      def create
        @asset = if params[:asset][:upload]
          ext = File.extname(params[:asset][:upload].original_filename)
          Asset.choose_type(ext.split('.').last)
        else
          Asset.new
        end

        persist!(@asset)
      end

      private

      def find_category
        id = params[:asset] ? params[:asset][:asset_category_id] : params[:asset_category_id]
        @asset_category = AssetCategory.find(id) if id
      end
    end
  end
end
