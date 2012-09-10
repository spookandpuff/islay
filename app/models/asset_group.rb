class AssetGroup < ActiveRecord::Base
  include Hierarchy

  attr_accessible :name, :asset_group_id
  class_attribute :kind

  track_user_edits

  # Returns the ID of the parent if there is one.
  #
  # @return [ProductCategory, nil]
  def asset_group_id
    parent.id if parent
  end

  # Sets the parent via it's ID. If ID is #blank? it does nothing.
  #
  # @param [Integer, String] id
  #
  # @return [ProductCategory, nil]
  def asset_group_id=(id)
    self.parent = AssetCollection.find(id) unless id.blank?
  end

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
