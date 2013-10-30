class Islay::Admin::SearchController < Islay::Admin::ApplicationController
  header 'Search Results'

  helper_method :searchable_name, :searchable_path

  def index
    @results = PgSearch.multisearch(params[:term])
    if request.xhr?
      json = @results.map do |r|
        {
          :name => searchable_name(r.searchable),
          :type => r.searchable_type,
          :url => searchable_path(r.searchable)
        }
      end

      render :json => json
    end
  end

  # A helper which tries to figure out the name of a searchable model based
  # on the methods it responds to.
  #
  # @param ActiveRecord::Base searchable
  # @return String
  # @todo This is actually crude and should be replaced in the future. Perhaps 
  #       with a partial per search result.
  def searchable_name(searchable)
    if searchable.respond_to?(:searchable_name)
      searchable.searchable_name
    elsif searchable.respond_to?(:name)
      searchable.name
    elsif searchable.respond_to?(:title)
      searchable.title
    else
      '--'
    end
  end

  # In the general case this will just pass the searchable class off to the 
  # #path helper, but where it's dealing with a nested resource, it will
  # interrogate the model to find out what it's search opts are and use those.
  #
  # @param ActiveRecord::Base searchable
  # @return String
  # @todo The path opts probably shouldn't come from the model
  def searchable_path(searchable)
    if searchable.respond_to?(:searchable_url_opts)
      path(*searchable.searchable_url_opts)
    else
      path(searchable)
    end
  end
end
