class AssetGroup < ActiveRecord::Base
  attr_accessible :name, :asset_group_id
  class_attribute :kind

  track_user_edits

  # Returns a relation with calculated fields for the last update and the types
  # of assets it contains.
  #
  # @return ActiveRecord::Relation
  def self.summary
    select(%{
      asset_groups.*,
      (SELECT name FROM users WHERE id = updater_id) AS updater_name
    })
  end

  def album?
    type == 'AssetAlbum'
  end

  def collection?
    type == 'AssetCollection'
  end
end
