class CreatePageAssets < ActiveRecord::Migration[4.2]
  def change
    create_table :page_assets do |t|
      t.integer :page_id,   :null => false, :on_delete => :cascade
      t.integer :asset_id,  :null => false, :on_delete => :cascade
      t.string  :name,      :null => false, :limit => 50
    end
  end
end
