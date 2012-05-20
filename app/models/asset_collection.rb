class AssetCollection < AssetGroup
  has_many :children,    :class_name => 'AssetGroup',       :foreign_key => 'asset_group_id', :order => 'type DESC, name DESC'
  has_many :collections, :class_name => 'AssetCollection',  :foreign_key => 'asset_group_id'
  has_many :albums,      :class_name => 'AssetAlbum',       :foreign_key => 'asset_group_id'
  has_many :assets,      :through => :albums

  self.kind = 'collection'
end
