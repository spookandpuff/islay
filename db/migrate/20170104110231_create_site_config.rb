class CreateSiteConfig < ActiveRecord::Migration[4.2]
  def change
    create_table :site_configs do |t|
      t.string :key, :null => false, :limit => 128
      t.string :name, :null => false, :limit => 128

      t.json :configuration_info, :default => {}
      t.json :configuration, :default => {}

      t.timestamps
    end
  end
end