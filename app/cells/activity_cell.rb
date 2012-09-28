class ActivityCell < Cell::Rails
  def log
    @logs = ActivityLog.recent
    render
  end
end
