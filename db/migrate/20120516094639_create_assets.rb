class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.integer   :asset_category_id,   :null => false, :on_delete => :cascade
      t.string    :type,                :null => false, :limit => 50
      t.string    :name,                :null => false, :limit => 200, :index => :unique
      t.string    :status,              :null => false, :default => 'pending'
      t.string    :upload,              :null => false, :limit => 200
      t.string    :path,                :null => false, :limit => 200
      t.integer   :filesize,            :null => true,  :precision => 20, :scale => 0
      t.string    :content_type,        :null => true,  :limit => 100
      t.boolean   :under_size,          :null => false, :default => false
      t.string    :colour_space,        :null => true

      t.integer   :creator_id, :null => false, :references => :users
      t.integer   :updater_id, :null => false, :references => :users

      t.timestamps
    end
  end
end
