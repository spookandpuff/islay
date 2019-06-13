module RolesConcern
  extend ActiveSupport::Concern

  included do
    metadata(:metadata) do
      boolean :can_log_in, default: true
      bitmask :roles_mask, as: 'check_boxes', values: :valid_roles, label: 'Roles', required: true
    end

    def self.roles(*roles)
      @@roles_list = roles if roles.present?
      @@roles_list
    end
  end

  def valid_roles
    self.class.roles
  end

  def roles
    roles_mask
  end

  def has_role?(role)
    roles.include?(role)
  end

  def assign_role(role)
    raise "Invalid Role #{role}" unless valid_roles.include?(role)
    roles_mask = (roles << role).uniq
  end
end
