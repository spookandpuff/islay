class CreateAssetTags < ActiveRecord::Migration[4.2]
  def change
    create_table :asset_tags do |t|
      t.string :name, :null => false, :limit => 200
      t.string :slug, :null => false, :limit => 200, :unique => true
    end
  end
end
