class UserLogDecorator < LogDecorator
  delegate_all
  
  def url
    h.admin_user_path(model.id)
  end
end
