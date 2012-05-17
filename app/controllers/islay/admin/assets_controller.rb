module Islay
  module Admin
    class AssetsController < ApplicationController
      resourceful :asset
      header 'Asset Library'

      def create
        @asset = if params[:asset][:upload]
          ext = File.extname(params[:asset][:upload].original_filename)
          Asset.choose_type(ext.split('.').last)
        else
          Asset.new
        end

        logger.debug("WHAT IS THIS? #{@asset.inspect}")

        persist!(@asset)
      end
    end
  end
end
