class UserActionLog < ActiveRecord::Base
  belongs_to :target, polymorphic: true
  belongs_to :user

  def self.for(user, action, target_object, opts = {})
    new.tap do |log|
      log.user         = user
      log.action       = action
      log.target       = target_object
      log.notes        = opts[:notes] if opts[:notes].present?
      log.payload      = opts[:payload] || {}

      log.save
    end
  end

  # A finder method which returns the n latest logs.
  #
  # @return Array<Draper::Base>
  def self.recent(count = 25)
    order("created_at DESC").limit(count)
  end

  def self.for_user(user)
    where(user: user)
  end

  def description
    target ? target.action_log_description : '-'
  end

  def url_params
    target ? target.action_log_url_params : '-'
  end

  check_for_extensions
end
