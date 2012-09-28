class LogDecorator < Draper::Base
  def created_at
    Time.new(model.created_at)
  end

  def url
    raise NotImplementedError
  end
end
