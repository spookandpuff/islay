class AssetCategory < ActiveRecord::Base
  has_many :assets
  has_many :images,     :class_name => 'ImageAsset'
  has_many :documents,  :class_name => 'DocumentAsset'
  has_many :videos,     :class_name => 'VideoAsset'

  attr_accessible :name

  track_user_edits
end
