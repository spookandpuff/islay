module Islay
  module Admin
    class AssetsController < ApplicationController
      resourceful :asset
      header 'Asset Library'

      before_filter :find_album, :only => [:new, :create]

      def create
        @asset = if params[:asset][:upload]
          ext = File.extname(params[:asset][:upload].original_filename)
          Asset.choose_type(ext.split('.').last)
        else
          Asset.new
        end

        persist!(@asset)
      end

      def reprocess
        @asset = Asset.find(params[:id])
        @asset.enqueue_upload_background_job
        redirect_to path(@asset)
      end

      private

      def find_album
        id = params[:asset] ? params[:asset][:asset_group_id] : params[:asset_album_id]
        @asset_group = AssetAlbum.find(id) if id
      end
    end
  end
end
