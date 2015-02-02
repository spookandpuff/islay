class AssetGroup < ActiveRecord::Base
  # include Hierarchy

  has_many :assets, -> {order("name")}, :foreign_key => 'asset_group_id'
  class_attribute :kind
  track_user_edits

  # Returns all the groups that are at the top i.e. have no parent.
  #
  # @return ActiveRecord::Relation
  def self.top_level
    where("path IS NULL or path = ?", '')
  end

  # @todo Actually implement this
  def children
    []
  end

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
    self.parent = AssetGroup.find(id) unless id.blank?
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
