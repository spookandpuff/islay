class User < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :validatable
  attr_accessible :name, :email, :password

  before_destroy :check_immutable_flag
  before_save    :check_immutable_flag
  validations_from_schema

  # Returns the system user. This is an always-present, immutable user used for
  # logging actions made by Islay e.g. migrations, background tasks etc.
  #
  # @return User
  def self.system
    where(:email => 'system@spookandpuff.com').first
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

  # Check if this record is destroyable
  #
  # @returns Boolean
  def destroyable?
    !(new_record? or immutable)
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
end
