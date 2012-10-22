class AlterAssetGroupsRemoveInheritance < ActiveRecord::Migration
  def up
    remove_column(:asset_groups, :type)
  end

  def down
    add_column(:asset_groups, :type, :string)
  end
end
