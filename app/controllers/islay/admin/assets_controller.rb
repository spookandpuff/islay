module Islay
  module Admin
    class AssetsController < ApplicationController
      resourceful :asset
      header 'Asset Library'
      nav 'islay/admin/asset_library/nav'

      before_filter :set_params, :only => :update

      def index
        klass = case params[:filter]
        when 'images'    then ImageAsset
        when 'documents' then DocumentAsset
        when 'videos'    then VideoAsset
        when 'audio'     then AudioAsset
        else Asset
        end

        @assets = klass.page(params[:page]).order('name')
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

      def processing
        @assets = Asset.filtered(params[:filter]).sorted(params[:sort])
      end

      def bulk_reprocess
        if params[:all]
          Asset.all.each(&:reprocess!)
        else
          Asset.where(:id => params[:ids]).each(&:reprocess!)
        end

        bounce_back
      end

      def reprocess
        @asset = Asset.find(params[:id])
        @asset.reprocess!
        redirect_to path(@asset)
      end

      private

      # This is a bit of a hack to make this controller play nice with the
      # resourceful declaration. Basically, the param names are inferred from the
      # symbol you pass to the ::resourceful method. This unfortunately doesn't
      # play nice when we use reuse a controller for single-inheritance
      # models. Hence this hack here.
      #
      # @todo Fix this nonsense.
      def set_params
        params[:asset] = params.delete("#{params[:type]}_asset")
      end
    end
  end
end
