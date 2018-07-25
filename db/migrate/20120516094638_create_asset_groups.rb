class CreateAssetGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :asset_groups do |t|
      t.string    :type,            :null => false, :limit => 50
      t.string    :name,            :null => false, :limit => 200
      t.integer   :assets_count,    :null => false, :length => 10, :default => 0
      t.integer   :creator_id,      :null => false, :references => :users
      t.integer   :updater_id,      :null => false, :references => :users

      t.timestamps
    end

    add_column(:asset_groups, :terms, :tsvector)
    add_column(:asset_groups, :path, :ltree, :null => true)
  end
end
