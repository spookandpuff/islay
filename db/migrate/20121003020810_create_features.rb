class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.integer :page_id,   :null => false, :on_delete => :cascade
      t.integer :asset_id,  :null => true,  :on_delete => :set_null

      t.integer :position,        :null => false, :limit => 3,  :default => 1
      t.string  :title,           :null => false, :length => 200
      t.string  :description,     :null => false, :length => 4000
      t.string  :styles,          :null => true,  :length => 4000

      t.publishing
      t.user_tracking
      t.timestamps
    end
  end
end
