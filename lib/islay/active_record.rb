class ActiveRecord::Base
  private

  # Provides access to the user model provided by Devise.
  def current_user
    Thread.current[:current_user]
  end

  # A callback handler which updates the user ID columns before save
  def update_user_ids
    if current_user
      self.creator_id = current_user.id if new_record?
      self.updater_id = current_user.id
    end
  end

  # Installs a before_save hook for updating the user IDs against a record.
  # This requires the creator_id and updater_id columns to be in the table.
  #
  # This method also installs to associations; creator, updater
  def self.track_user_edits
    before_save :update_user_ids
    belongs_to :creator, :class_name => 'User'
    belongs_to :updater, :class_name => 'User'
  end
end
