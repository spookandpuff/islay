class Islay::Admin::SearchController < Islay::Admin::ApplicationController
  header 'Search Results'

  def index
    @results = Search.search(params[:term])
  end
end
