# This module contains helpers and some ancillary classes for rendering 
# elements into the Admin's header. It is mixed into the ApplicationHelper so
# that it is available throughout the admin.
module Islay::Admin::HeaderHelper
  # Adds an entry to the breadcrumbs collection, which will be rendered at a
  # later point.
  #
  # @param String title
  # @param link_opts
  # @return nil
  def breadcrumb(title, *link_opts)
    @islay_breadcrumbs ||= []
    @islay_breadcrumbs << {:title => title, :opts => link_opts}
    nil
  end

  # Traverses the ancestors of the specified object and generates a breadcrumb
  # for each. It relies on the object responding to #ancestors and #name.
  #
  # @param Class
  # @return nil
  def ancestor_breadcrumbs(object)
    object.ancestors.each {|a| breadcrumb(a.name, a)}
    breadcrumb(object.name, object)
  end
  
  # Conditionally renders breadcrumbs for the current page. It only renders if
  # they have actually been defined.
  #
  # @return [String, nil]
  def render_breadcrumbs
    if @islay_breadcrumbs and !@islay_breadcrumbs.empty?
      render(
        :partial => 'islay/admin/shared/breadcrumbs', 
        :locals => {:breadcrumbs => @islay_breadcrumbs}
      )
    end
  end

  # Define a status flag to be displayed in the header.
  #
  # @param String title
  # @param [String, Numeric] value
  # @param Hash opts
  # @return nil
  def status(title, value, opts = {})
    @islay_statuses ||= []
    status = {:mode => :default, :title => title, :value => value}.merge(opts)
    @islay_statuses << status
    nil
  end

  # Conditionally renders status notices for the header. Only renders them if
  # they have actually been defined.
  #
  # @return [String, nil]
  def render_statuses
    if @islay_statuses and !@islay_statuses.empty?
      render(
        :partial => 'islay/admin/shared/statuses',
        :locals => {:statuses => @islay_statuses}
      )
    end
  end

  # Adds an entry into the filter navigation, which appears below the
  # sub-navigation. Typically used to filter lists of records.
  #
  # @param Symbol route the route set to use to generate link
  # @param String name to display
  # @param String by the field to filter by
  # @return nil
  def filter_nav(route, name, by = nil)
    @islay_filter_nav ||= {:entries => []}

    if by
      url = path(:filter_and_sort, route, :filter => by, :sort => params[:sort], :page => params[:page])
      if request.original_url.match(%r{^#{url}})
        @islay_filter_nav[:current] = url
        @islay_filter_nav[:entries] << [name, url, true]
      else
        @islay_filter_nav[:entries] << [name, url]
      end
    else
      url = path(:filter_and_sort, route, :filter => nil, :sort => params[:sort], :page => params[:page])
      entry = [name, url]
      @islay_filter_nav[:default] = entry
      @islay_filter_nav[:entries] << entry
    end

    nil
  end

  # Conditionally renders filters for the header. Only renders them if they 
  # have actually been defined.
  #
  # @return [String, nil]
  def render_filter_nav
    if @islay_filter_nav and !@islay_filter_nav.empty?
      if !@islay_filter_nav[:current] and @islay_filter_nav[:default]
        @islay_filter_nav[:default] << true
      end

      render(
        :partial => 'islay/admin/shared/filter_nav',
        :locals => {:filters => @islay_filter_nav[:entries]}
      )
    end
  end

  # Adds an entry into the sort navigation. This is a control which allows
  # uses to change the order in which lists of records are displayed.
  #
  # @param Symbol route the route set to use to generate link
  # @param String name to display
  # @param String by the field to sort by
  #
  # @return Hash<Array>
  def sort_nav(route, name, by = nil)
    @islay_sort_nav ||= {:entries => []}

    if by
      url = path(:filter_and_sort, route, :sort => by, :filter => params[:filter], :page => params[:page])
      if request.original_url.match(%r{^#{url}})
        @islay_sort_nav[:current] = url
        @islay_sort_nav[:entries] << [name, url, true]
      else
        @islay_sort_nav[:entries] << [name, url]
      end
    else
      url = path(:filter_and_sort, route, :sort => nil, :filter => params[:filter], :page => params[:page])
      entry = [name, url]
      @islay_sort_nav[:default] = entry
      @islay_sort_nav[:entries] << entry
    end
  end

  # Conditionally renders sort nav for the header. Only renders them if they 
  # have actually been defined.
  #
  # @return [String, nil]
  def render_sort_nav
    if @islay_sort_nav and !@islay_sort_nav.empty?
      if !@islay_sort_nav[:current] and @islay_sort_nav[:default]
        @islay_sort_nav[:default] << true
      end

      render(
        :partial => 'islay/admin/shared/sort_nav',
        :locals => {:entries => @islay_sort_nav[:entries]}
      )
    end
  end
end

