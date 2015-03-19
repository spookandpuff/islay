class Islay::Admin::FeaturesController < Islay::Admin::ApplicationController
  header 'Page Features'
  resourceful :feature

  before_filter :find_page

  private

  def redirect_for(feature)
    path(:edit, @page)
  end

  def find_page
    @page = Page.where(:slug => params[:page_id]).first
  end

  def dependencies
    @assets = ImageAsset.order('name')
  end

  def feature_params
    params[:feature].permit(:primary_asset_id, :secondary_asset_id, :title, :description, :styles, :position, :published, :link_url, :link_title, :page_id)
  end
end
