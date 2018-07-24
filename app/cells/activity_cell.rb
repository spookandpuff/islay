class ActivityCell < Islay::ApplicationCell
  def log
    @logs = ActivityLog.recent
    render
  end
end
