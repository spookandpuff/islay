module Islay
  module AdminController
    def self.included(klass)
      klass.class_eval do
        include InstanceMethods
        extend ClassMethods

        layout 'layouts/islay/application'
        before_filter :authenticate_user!, :store_user_in_thread

        class_attribute :_header, :_route_scopes
        helper_method :_header

        self._route_scopes = {}

        helper_method :path
      end
    end

    module InstanceMethods
      private

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

    module ClassMethods
      def header(name)
        self._header = name
      end

      def resourceful(model, opts = {})
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

        include ResourcefulMethods
      end
    end

    module ResourcefulMethods
      def index
        records = resource_class[:class].all
        instance_variable_set("@#{resource_class[:plural]}", records)
      end

      def show
        record = resource_class[:class].find(params[:id])
        set_ivar(record)
      end

      def new
        set_ivar(new_record)
        dependencies
      end

      def create
        persist! set_ivar(new_record)
      end

      def edit
        record = resource_class[:class].find(params[:id])
        set_ivar(record)
        dependencies
      end

      def update
        record = resource_class[:class].find(params[:id])
        set_ivar(record)
        persist!(record)
      end

      def delete

      end

      def destroy
        record = resource_class[:class].find(params[:id])
        record.destroy
        redirect_to url_for([:admin, resource_class[:plural]])
      end

      private

      def persist!(record)
        if record.update_attributes(params[resource_class[:name]])
          redirect_to(redirect_for(record))
        else
          dependencies
          render(record.new_record? ? :new : :edit)
        end
      end

      def redirect_for(record)
        url_for([:admin, record])
      end

      # Can be over-ridden in subclasses to provide the data needed when
      # rendering a form.
      def dependencies

      end

      def new_record
        resource_class[:class].new
      end

      def set_ivar(record)
        instance_variable_set("@#{resource_class[:name]}", record)
      end

      def find_parent
        parent = resource_parent[:class].find(resource_parent[:param])
        instance_variable_set("@#{resource_parent[:name]}", parent)
      end
    end
  end
end
