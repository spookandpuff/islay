class AssetGroup < ActiveRecord::Base
  attr_accessible :name, :asset_group_id
  class_attribute :kind

  acts_as_nested_set :parent_column => 'asset_group_id', :counter_cache => :children_count
  track_user_edits

  def album?
    type == 'AssetAlbum'
  end

  def collection?
    type == 'AssetCollection'
  end
end
