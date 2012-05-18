class AssetAlbum < AssetGroup
  has_many :assets,     :foreign_key => 'asset_group_id'
  has_many :images,     :class_name => 'ImageAsset',    :foreign_key => 'asset_group_id'
  has_many :documents,  :class_name => 'DocumentAsset', :foreign_key => 'asset_group_id'
  has_many :videos,     :class_name => 'VideoAsset',    :foreign_key => 'asset_group_id'

  belongs_to :collection, :class_name => 'AssetCollection', :foreign_key => 'asset_group_id'

  self.kind = 'album'
end
