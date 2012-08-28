class PageAsset < ActiveRecord::Base
  belongs_to :page
  belongs_to :asset

  attr_accessible :page_id, :name, :asset_id
end
