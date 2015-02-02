module ActiveRecord
  module ConnectionAdapters
    class TableDefinition
      # This is a migration helper for adding columns used when tracking user
      # edits to records. It works in conjunction with the extensions to AR:Base.
      def user_tracking(nullable = false)
        column(:creator_id, :integer, :null => nullable, :references => :users)
        column(:updater_id, :integer, :null => nullable, :references => :users)
      end

      def publishing
        column(:published, :boolean, :null => false, :default => :false)
        column(:published_at, :timestamp, :null => true)
        column(:first_published_at, :timestamp, :null => true)
      end
    end
  end

  class Base
    # Indicates if the record can be destroyed. By default this is true, but for
    # some sub-classes it should be over-ridden.
    #
    # @return Boolean
    def destroyable?
      true
    end

    private
    # This is a dirty hack which allows us to extend models within an application
    # by adding a corresponding file in ./app/model_extensions.
    def self.check_for_extensions
      target = File.join(Rails.root, "app/models/#{self.to_s.underscore}_extensions.rb")
      require_dependency(target) if File.exists?(target)
    end

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
    # This method also installs two associations; creator, updater
    #
    # @return nil
    def self.track_user_edits
      before_save :update_user_ids
      belongs_to :creator, :class_name => 'User'
      belongs_to :updater, :class_name => 'User'
      User.track_class(self)
      nil
    end

    # Checks to see if the specified column should have a required validation or
    # not.
    def self.nullable(col)
      col.null or (!col.null and !col.default.nil?)
    end
  end # Base
end # ActiveRecord
