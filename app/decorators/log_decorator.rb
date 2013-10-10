class LogDecorator < Draper::Base
  def created_at
    model.created_at.to_time
  end

  def url
    raise NotImplementedError
  end
end
