class CreateActivityLogs < ActiveRecord::Migration
  def change
    create_table :activity_logs do |t|
      t.string    :source,          :limit => 25,  :null => false
      t.string    :key,             :limit => 25,  :null => false
      t.string    :classification,  :limit => 25,  :null => false
      t.string    :action,          :limit => 25,  :null => true
      t.string    :description,     :limit => 300, :null => false
      t.hstore    :details,         :null => true
      t.integer   :user_id,         :null => true, :on_delete => :set_null
      t.integer   :person_id,       :null => true, :on_delete => :set_null
      t.integer   :loggable_id,     :null => true, :references => nil
      t.string    :loggable_type,   :null => true, :length => 50
      t.timestamp :created_at,      :null => false
    end
  end
end
