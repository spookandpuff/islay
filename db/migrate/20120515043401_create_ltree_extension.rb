class CreateLtreeExtension < ActiveRecord::Migration[4.2]
  def up
    execute "CREATE EXTENSION ltree"
  end

  def down
    execute "DROP EXTENSION ltree"
  end
end
