class User < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :validatable

  before_destroy :check_immutable_flag
  before_save    :check_immutable_flag

  validations_from_schema

  include PgSearch
  multisearchable :against => [:name, :email]

  # Returns the system user. This is an always-present, immutable user used for
  # logging actions made by Islay e.g. migrations, background tasks etc.
  #
  # @return User
  def self.system
    where(:email => 'system@spookandpuff.com').first
  end

  def self.filtered(filter)
    case filter
    when 'all' then scoped
    when 'disabled' then where(:disabled => true)
    else where(:disabled => false)
    end
  end

  # Returns a scope that sorts the results by the provided field. This behaves
  # close to ::order except that it defaults to sorting by :name.
  #
  # @param [String, nil] sort
  def self.sorted(sort)
    order(sort || :name)
  end

  # Class attributes for storing the assocations generated when registering
  # classes to be 'tracked'. See ::track_class
  class_attribute :creator_association_names, :updater_association_names
  self.creator_association_names = Set.new
  self.updater_association_names = Set.new

  # Allows classes to register themselves as being tracked for user edits. This
  # method is only intended to be used within Islay's API. You should not call
  # it directly.
  #
  # @param ActiveRecord::Base klass
  # @return nil
  # @api private
  def self.track_class(klass)
    creator_assoc = :"created_#{klass.to_s.underscore.pluralize}"
    updater_assoc = :"updated_#{klass.to_s.underscore.pluralize}"

    has_many creator_assoc, :class_name => klass.to_s, :foreign_key => :creator_id
    has_many updater_assoc, :class_name => klass.to_s, :foreign_key => :updater_id

    creator_association_names.add(creator_assoc)
    updater_association_names.add(updater_assoc)

    nil
  end

  # A predictate which checks to see if the user has created or modified any
  # records.
  #
  # This value is memoised.
  #
  # @return [true, false]
  def modified_records?
    @modified_records ||= begin
      created = creator_association_names.map {|name| send(name).select("id").to_sql}
      updated = updater_association_names.map {|name| send(name).select("id").to_sql}

      count = self.class.count_by_sql(%{
        SELECT
          CASE
            WHEN EXISTS (
              SELECT 1 FROM (
                #{(created + updated).join(' UNION ')}
              ) AS created
            ) THEN 1
            ELSE 0
          END AS count
      })

      count == 1
    end
  end

  # This is a cheeky little writer that just prevents anyone from externally
  # modifying the immutable attribute. It ignores the input.
  #
  # @param [true, false] bool
  #
  # @returns nil
  def immutable=(bool)
    nil
  end

  # Checks if this record is destroyable. This is only true if the user has not
  # ever created or edited any records.
  #
  # This overrides the default implementation.
  #
  # @return [true, false]
  def destroyable?
    !new_record? and !immutable? and !modified_records?
  end

  private

  class ImmutableRecordError < StandardError
    def to_s
      "This record is immutable and cannot be modified or deleted"
    end
  end

  # Check to make sure the only users marked as destroyable can actually be
  # removed from the system.
  #
  # @returns nil
  #
  # @raises ImmutableRecordError
  def check_immutable_flag
    if immutable
      raise ImmutableRecordError.new
    end
  end

  # This is a tweaked version of Devise's implementation of this method. We
  # inject an extra condition to restrict the results to records that are not
  # disabled.
  #
  # @return [User, nil]
  def self.find_for_database_authentication(conditions)
    find_for_authentication(conditions.merge("disabled" => false))
  end

  protected

  # This overwrites the default implementation provided by
  # Devise::Models::Validatable. It ignores blanks strings.
  #
  # @return [true, false]
  def password_required?
    !persisted? || !password.blank? || !password_confirmation.blank?
  end
end
