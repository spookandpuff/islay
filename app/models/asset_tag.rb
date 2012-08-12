class AssetTag < Tag
  extend FriendlyId
  friendly_id :name, :use => :slugged

  has_many :taggings, :class_name => 'AssetTagging'
  has_many :assets,   :through => :taggings

  # Creates a scope with calulcated fields for summarising the tags e.g. with
  # count of entries etc.
  #
  # @return ActiveRecord::Relation
  def self.summary
    select("asset_tags.id, asset_tags.slug, asset_tags.name, COUNT(assets.id) AS assets_count")
      .joins(:assets)
      .group("asset_tags.id, asset_tags.name")
  end
end
