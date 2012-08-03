module Islay
  module Admin
    class ApplicationController < ActionController::Base
      layout 'layouts/islay/application'
      before_filter :authenticate_user!, :store_user_in_thread

      class_attribute :_header, :_route_scopes, :_nav
      helper_method :_header, :_nav

      self._route_scopes = {}

      helper_method :path

      private

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
          before_filter :find_parent
        end

        include Islay::ResourcefulController
      end


      def store_user_in_thread
        Thread.current[:current_user] = current_user
      end

      # A shortcut for generating routes namespaced to the Admin module.
      def path(*args)
        first, second, rest = args

        if first.is_a?(::ActiveRecord::Base)
          url_for([:admin, *args])
        elsif first.is_a?(Symbol)
          if second.is_a?(::ActiveRecord::Base) || second.is_a?(Symbol)
            url_for([first, :admin, second, *rest])
          else
            url_for([:admin, *args])
          end
        end
      end
    end
  end
end
