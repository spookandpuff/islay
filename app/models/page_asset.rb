class PageAsset < ActiveRecord::Base
  belongs_to :page
  belongs_to :asset
end
