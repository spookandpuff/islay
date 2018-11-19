class AlterAssetsAddMetadata < ActiveRecord::Migration[4.2]
  def change
    add_column :assets, :metadata, :hstore, :null => true
  end
end
