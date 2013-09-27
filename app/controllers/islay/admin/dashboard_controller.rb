class Islay::Admin::DashboardController < Islay::Admin::ApplicationController
  header 'Dashboard'

  def index

  end

  def add_item
    render :layout => false if request.xhr?
  end
end