class Islay::Admin::Users::InvitationsController < Devise::InvitationsController
  include Islay::Admin::ExtensibleStylesheetConcern
  include Islay::Admin::FeedbackConcern

  layout 'islay/login'

  private

  def after_sign_in_path_for(resource)
    admin_root_url
  end

end
