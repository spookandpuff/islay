class AssetTagging < ActiveRecord::Base
  belongs_to :asset
  belongs_to :tag, :class_name => 'AssetTag', :foreign_key => 'asset_tag_id'

  attr_accessible :tag
end
