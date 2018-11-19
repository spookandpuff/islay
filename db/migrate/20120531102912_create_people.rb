class CreatePeople < ActiveRecord::Migration[4.2]
  def change
    create_table :people do |t|
      t.string :name,   :null => false, :limit => 200
      t.string :email,  :null => false, :limit => 200

      t.timestamps
    end
  end
end
