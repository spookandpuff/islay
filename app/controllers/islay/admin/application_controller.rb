module Islay
  module Admin
    class ApplicationController < ActionController::Base
      include Islay::AdminController

      class_attribute :_header
      helper_method :_header

      def self.header(name)
        self._header = name
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

        include InstanceMethods
      end

      module InstanceMethods
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
            redirect_to url_for([:admin, record])
          else
            dependencies
            render(record.new_record? ? :new : :edit)
          end
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
end
