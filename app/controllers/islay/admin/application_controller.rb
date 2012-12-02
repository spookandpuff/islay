module Islay
  module Admin
    class ApplicationController < Islay::ApplicationController
      use_https

      layout 'layouts/islay/application'
      before_filter :authenticate_user!, :store_user_in_thread

      class_attribute :_header, :_route_scopes, :_nav
      helper_method :_header, :_nav

      self._route_scopes = {}

      helper_method :path

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

      def self.resourceful(model, opts = {})
        class_attribute :resource_class
        class_attribute :resource_parent

        self.resource_class = {
          :class   => model.to_s.classify.constantize,
          :name    => model,
          :plural  => model.to_s.pluralize
        }
        attr_reader model

        if parent = opts[:parent]
          self.resource_parent = {
            :class  => parent.to_s.classify.constantize,
            :name   => parent,
            :param  => :"#{parent}_id"
          }
          attr_reader parent
          before_filter :find_parent, :except => [:delete]
        end

        include Islay::ResourcefulController
      end


      def store_user_in_thread
        Thread.current[:current_user] = current_user
      end

      # A shortcut for generating routes namespaced to the Admin module.
      def path(*args)
        opts = args.pop if args.last.is_a?(Hash)
        first, second, rest = args

        url_opts = if first.is_a?(::ActiveRecord::Base)
          [[:admin, *args], opts]
        elsif first.is_a?(Symbol)
          if second.is_a?(::ActiveRecord::Base) || second.is_a?(Symbol)
            [[first, :admin, second, *rest], opts]
          else
            [[:admin, *args], opts]
          end
        end

        url_opts.compact!

        polymorphic_url(*url_opts)
      end
    end
  end
end
