class Ability
  include CanCan::Ability

  # This is the everyone-do-everything default ability.
  # It's designed to be overridden as required in the including app
  def initialize(user)
    can :manage, :all if user.present?
  end
end
