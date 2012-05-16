class CreateAssetCategories < ActiveRecord::Migration
  def change
    create_table :asset_categories do |t|
      t.integer   :asset_category_id,   :null => true,  :on_delete => :cascade
      t.string    :name,                :null => false, :limit => 200, :index => :unique

      t.integer   :creator_id, :null => false, :references => :users
      t.integer   :updater_id, :null => false, :references => :users

      t.timestamps
    end
  end
end
