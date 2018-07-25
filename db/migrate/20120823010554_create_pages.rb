class CreatePages < ActiveRecord::Migration[4.2]
  def change
    create_table :pages do |t|
      t.string :slug,     :null => false, :limit => 50
      t.hstore :entries,  :null => true

      t.user_tracking
      t.timestamps
    end
  end
end
