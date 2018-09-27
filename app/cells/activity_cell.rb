class ActivityCell < Islay::ApplicationCell
  def log
    @user_logs = UserActionLog.recent.for_user(current_user)
    @global_logs = ActivityLog.recent
    render
  end
end
