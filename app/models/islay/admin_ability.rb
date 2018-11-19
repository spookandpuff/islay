class Islay::AdminAbility
  include CanCan::Ability

  attr_accessor :user

  # This is the everyone-do-everything default ability.
  # It's designed to be overridden as required in the including app
  def initialize(user)
    @user = user || User.new

    can :manage, :all if user.present?

    meta_abilities
  end

  # Top level 'meta-abilities' used for selectively displaying content
  # These are loaded with a 'do_' prefix. 'do_admin', 'do_manager' etc
  def meta_abilities
    User.roles.each do |(k, v)|
      if user.has_role? k
        can "do_#{k}".to_sym, :all
      end
    end
  end
end
