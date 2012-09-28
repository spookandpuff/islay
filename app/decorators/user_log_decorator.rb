class UserLogDecorator < LogDecorator
  def url
    h.admin_user_path(model.id)
  end
end
