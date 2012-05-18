class AssetGroup < ActiveRecord::Base
  attr_accessible :name, :asset_group_id
  class_attribute :kind

  track_user_edits

  def album?
    type == 'AssetAlbum'
  end

  def collection?
    type == 'AssetCollection'
  end
end
