class Islay::Admin::AssetBulkUploadsController < Islay::Admin::ApplicationController
  before_filter :initialize_upload_and_find_group

  def new

  end

  def create
    @asset_bulk_upload.upload = params[:asset_bulk_upload][:upload]

    if @asset_bulk_upload.valid?
      @asset_bulk_upload.enqueue
      redirect_to path(@asset_group)
    else
      render :new
    end
  end

  private

  def initialize_upload_and_find_group
    @asset_group        = AssetGroup.find(params[:asset_group_id])
    @asset_bulk_upload  = AssetBulkUpload.new(:asset_group_id => params[:asset_group_id])
  end
end
