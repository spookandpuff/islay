class SetupHstore < ActiveRecord::Migration[4.2]
  def self.up
    execute "CREATE EXTENSION hstore"
  end

  def self.down
    execute "DROP EXTENSION hstore"
  end
end
