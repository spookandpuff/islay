class LogDecorator < Draper::Base
  decorates :activity_log

  def created_at
    Time.new(model.created_at)
  end

  def url
    raise NotImplementedError
  end
end
