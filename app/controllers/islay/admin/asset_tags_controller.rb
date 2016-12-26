class Islay::Admin::AssetTagsController < Islay::Admin::ApplicationController
  header 'Asset Library - Tags'
  nav_scope :asset_library

  def index
    @asset_tags = AssetTag.summary.order('name')
  end

  def show
    @asset_tag  = AssetTag.where(slug: params[:id]).first
    @assets     = @asset_tag.assets.page(params[:page]).order("name")
  end
end