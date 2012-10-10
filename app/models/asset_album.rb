class AssetAlbum < AssetGroup
  has_many :assets,     :foreign_key => 'asset_group_id', :order => 'name'
  has_many :images,     :class_name => 'ImageAsset',    :foreign_key => 'asset_group_id', :order => 'name'
  has_many :documents,  :class_name => 'DocumentAsset', :foreign_key => 'asset_group_id', :order => 'name'
  has_many :videos,     :class_name => 'VideoAsset',    :foreign_key => 'asset_group_id', :order => 'name'

  self.kind = 'album'

  # Creates a relation, where the only albums returned are those having the
  # specified asset types.
  #
  # @param [String, nil] only
  #
  # @return ActiveRecord::Relation
  def self.of(only)
    if only
      select("asset_groups.id, asset_groups.name, COUNT(assets) AS assets_count")
      .joins(sanitize_sql_array(["JOIN assets ON asset_group_id = asset_groups.id AND assets.type = ?", "#{only.singularize.capitalize}Asset"]))
      .group("asset_groups.id, asset_groups.name")
    else
      scoped
    end
  end
end
