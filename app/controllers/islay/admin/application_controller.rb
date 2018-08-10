class Islay::Admin::ApplicationController < Islay::ApplicationController
  use_https

  layout 'layouts/islay/application'
  before_action :authenticate_user!, :store_user_in_thread

  class_attribute :_header, :_route_scopes, :_nav, :_nav_scope
  helper_method :_header, :_nav, :nav_scope

  self._route_scopes = {}

  helper_method :path, :public_path

  def extension_style_sheet(path = nil)
    @extension_style_sheets ||= []
    @extension_style_sheets << path if path
    @extension_style_sheets
  end

  alias_method :extension_style_sheets, :extension_style_sheet

  helper_method :extension_style_sheets, :extension_style_sheet

  # A shortcut for generating routes namespaced to the Admin module.
  #
  # @param [Symbol, ActiveRecord::Base, Hash] args
  #
  # @return String
  def path(*args)
    render_path(:admin, args)
  end

  # A shortcut for generating routes namespaced to the Public module.
  #
  # @param [Symbol, ActiveRecord::Base, Hash] args
  #
  # @return String
  def public_path(*args)
    render_path(:public, args)
  end

  private

  # Intended to be run as a before filter, which will then draw out date/time
  # related params, coerce them and put them into a Hash.
  #
  # @return Hash
  def parse_dates
    @report_range = if params[:month] and params[:year]
      now       = Date.today
      date      = Date.new(params[:year].to_i, params[:month].to_i)
      last_day  = date.month == now.month ? now.mday : date.end_of_month.mday

      {
        :mode  => :month,
        :year  => params[:year].to_i,
        :month => params[:month].to_i,
        :days  => (1..last_day).map {|d| "#{d}/#{date.month}/#{date.year}"}
      }
    elsif params[:from] and params[:to]
      range = (Date.parse(params[:from])..Date.parse(params[:to]))

      {
        :mode => :range,
        :from => params[:from],
        :to   => params[:to],
        :days => range.map {|d| "#{d.mday}/#{d.month}/#{d.year}"}
      }
    else
      time = Time.now

      {
        :mode => :none,
        :days => (1..time.mday).map {|d| "#{d}/#{time.month}/#{time.year}"}
      }
    end
  end

  def self.header(name)
    self._header = name
  end

  # A declaration for defining the path to a template containing the
  # definition of a sub-navigation. This sub-navigation will then be
  # displayed for all actions in the controller.
  #
  # @param String path
  #
  # @return String
  def self.nav(path)
    self._nav = path
  end

  # A declaration for defining the navigation scope. This name corresponds to
  # the name used when defining navigation entries within the engine
  # initializers.
  #
  # @param Symbol name
  # @return Symbol
  def self.nav_scope(name)
    self._nav_scope = name
  end

  # Returns the nav scope for the current controller. This is the symbol
  # declared by the ::nav_scope class method.
  #
  # @return Symbol
  def nav_scope
    self.class._nav_scope
  end


  def self.resourceful(model, opts = {})
    class_attribute :resource_class
    class_attribute :resource_parent

    self.resource_class = if model.is_a? Symbol
      model_name = model
      {
        :class   => model.to_s.classify.constantize,
        :name    => model,
        :plural  => model.to_s.pluralize
      }
    else
      model_name = model.name.demodulize.underscore
      {
        :class   => model,
        :name    => model_name,
        :plural  => model_name.pluralize
      }
    end

    attr_reader model_name.to_sym

    if parent = opts[:parent]
      self.resource_parent = {
        :class  => parent.to_s.classify.constantize,
        :name   => parent,
        :param  => :"#{parent}_id"
      }
      attr_reader parent
      before_action :find_parent, :except => [:delete]
    end

    include Islay::ResourcefulController
  end


  def store_user_in_thread
    Thread.current[:current_user] = current_user
  end

end
