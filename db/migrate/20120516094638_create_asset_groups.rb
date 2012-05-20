class CreateAssetGroups < ActiveRecord::Migration
  def change
    create_table :asset_groups do |t|
      t.string    :type,            :null => false, :limit => 50
      t.string    :name,            :null => false, :limit => 200, :index => {:unique => true, :with => :asset_group_id}
      t.integer   :asset_group_id,  :null => true,  :on_delete => :cascade
      t.integer   :assets_count,    :null => false, :limit => 10, :default => 0
      t.integer   :creator_id,      :null => false, :references => :users
      t.integer   :updater_id,      :null => false, :references => :users

      t.timestamps
    end
  end
end
