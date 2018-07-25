class AlterUsersWithDisabledFlag < ActiveRecord::Migration[4.2]
  def up
    add_column(:users, :disabled, :boolean, :null => false, :default => false)
  end

  def down
    remove_column(:users, :disabled)
  end
end
