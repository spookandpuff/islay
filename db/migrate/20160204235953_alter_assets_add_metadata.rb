class AlterAssetsAddMetadata < ActiveRecord::Migration
  def change
    add_column :assets, :metadata, :hstore, :null => true
  end
end
