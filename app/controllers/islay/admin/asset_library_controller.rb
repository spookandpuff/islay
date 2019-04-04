class Islay::Admin::AssetLibraryController < Islay::Admin::ApplicationController
  header 'Asset Library'
  nav_scope :asset_library

  def index
    @groups         = AssetGroup.summary.order('name')
    @latest_assets  = Asset.limit(11).order("updated_at DESC")
    @asset_tags     = AssetTag.order('name')
  end

  def browser
    @albums = AssetGroup.of(params[:only]).order('name ASC')

    @assets = if params[:only]
      Asset.summaries.of(params[:only])
    else
      Asset.latest
    end

    render :layout => false
  end
end
