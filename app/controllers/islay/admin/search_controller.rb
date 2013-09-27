class Islay::Admin::SearchController < Islay::Admin::ApplicationController
  header 'Search Results'

  def index
    @results = Search.search(params[:term])
    if request.xhr?
      json = @results.map do |r|
        {
          :name => r.name,
          :type => r.searchable_type,
          :url => path(r.searchable)
        }
      end

      render :json => json
    end
  end
end
