class CreateAssetGroups < ActiveRecord::Migration
  def change
    create_table :asset_groups do |t|
      t.string    :type,            :null => false, :limit => 50
      t.integer   :asset_group_id,  :null => true,  :on_delete => :cascade
      t.string    :name,            :null => false, :limit => 200, :index => :unique

      t.integer   :creator_id,      :null => false, :references => :users
      t.integer   :updater_id,      :null => false, :references => :users

      t.timestamps
    end
  end
end
