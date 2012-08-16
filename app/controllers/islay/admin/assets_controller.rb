module Islay
  module Admin
    class AssetsController < ApplicationController
      resourceful :asset
      header 'Asset Library'
      nav 'islay/admin/asset_library/nav'

      def index
        klass = case params[:filter]
        when 'images'    then ImageAsset
        when 'documents' then DocumentAsset
        when 'videos'    then VideoAsset
        when 'audio'     then AudioAsset
        else Asset
        end

        @assets = klass.order('name')
      end

      def create
        @asset = if params[:asset][:file]
          ext = File.extname(params[:asset][:file].original_filename)
          Asset.choose_type(ext.split('.').last)
        else
          Asset.new
        end

        persist!(@asset)
      end

      def bulk
        @upload = AssetBulkUpload.new
      end

      def bulk_create
        @upload = AssetBulkUpload.new(params[:asset_bulk_upload])
        if @upload.valid?
          @upload.unpack!
          redirect_to path(@upload.album)
        else
          render :bulk
        end
      end

      def reprocess
        @asset = Asset.find(params[:id])
        @asset.enqueue_upload_background_job
        redirect_to path(@asset)
      end
    end
  end
end
