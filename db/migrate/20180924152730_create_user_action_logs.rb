class CreateUserActionLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :user_action_logs do |t|
      t.integer       :user_id,     null:  true,   on_delete:  :cascade
      t.references    :target,      polymorphic: true

      t.boolean       :succeeded,   null: false,  default:  true
      t.string        :action,      null: false,  limit:  20
      t.string        :notes,       null: true,   limit:  2000
      t.jsonb         :payload,     null: false,  default: {}

      t.timestamps
    end
  end
end
