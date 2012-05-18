class AssetCollection < AssetGroup
  has_many :collections, :class_name => 'AssetCollection',  :foreign_key => 'asset_group_id'
  has_many :albums,      :class_name => 'AssetAlbum',       :foreign_key => 'asset_group_id'

  self.kind = 'collection'
end
