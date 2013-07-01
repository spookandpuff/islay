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
    # This method also installs to associations; creator, updater
    def self.track_user_edits
      before_save :update_user_ids
      belongs_to :creator, :class_name => 'User'
      belongs_to :updater, :class_name => 'User'
    end

    # Checks to see if the specified column should have a required validation or
    # not.
    def self.nullable(col)
      col.null or (!col.null and !col.default.nil?)
    end

    # Extracts validations from the database schema, meaning there is no need
    # to essentially repeat the constraints in the model again.
    def self.validations_from_schema(opts = {})
      # Generate a list of columns to exclude
      except = ['creator_id', 'updater_id', 'created_at', 'updated_at']
      except += opts[:except].map(&:to_s) if opts[:except]

      # Grab the definitions for foreign keys and map them to the single column
      # name — we don't use composite keys — and a singular version of the table
      # name. This makes it easy to look up the relationship
      fks = self.foreign_keys.inject({}) do |h, k|
        h[k.column_names.first] = k.references_table_name.singularize
        h
      end

      self.columns.each do |col|
        # Don't check the primary key.
        # Don't check any columns we've expressly excluded
        unless col.primary or (!except.empty? and except.include?(col.name))
          # TODO: This validation is a bit inflexible.
          #
          # If this col has a foreign key and it's not null, validate the presence
          # of the associated model.
          #
          # Otherwise we check the column type and add constraints where necessary.
          if model = fks[col.name] and !col.null
          #   validates_presence_of model
          else
            case col.type
            when :integer
              # / 2 assumes signed!
              opts = {:only_integer => true, :allow_nil => nullable(col)}
              opts[:less_than] = (2 ** (8 * col.limit)) / 2 if col.limit
              validates_numericality_of col.name, opts
            when :float
              # less_than would need to look at col.scale, col.float
              validates_numericality_of col.name, :allow_nil => nullable(col)
            #when :time, :datetime
            when :string, :text
              if col.limit.to_i > 0 # Mysql enum type shows up as a string with a limit of 0
                validates_length_of col.name, :maximum => col.limit, :allow_nil => nullable(col)
              end
            when :boolean
              validates_inclusion_of col.name, :in => [true, false], :allow_nil => nullable(col)
            end

            # If the column is NOT NULL, validate it's presence.
            validates_presence_of col.name unless nullable(col)

            # TODO: Check for unique constraint
          end
        end
      end
    end # def validations_from_schema
  end # Base
end # ActiveRecord
