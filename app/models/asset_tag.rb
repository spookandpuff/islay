class AssetTag < Tag
  extend FriendlyId
  friendly_id :name, :use => :slugged

  has_many :taggings, :class_name => 'AssetTagging'
  has_many :assets,   :through => :taggings
end
