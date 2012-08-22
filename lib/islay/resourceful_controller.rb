module Islay
  module ResourcefulController
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
      persist!(set_ivar(new_record))
    end

    def edit
      set_ivar(find_record)
      dependencies
    end

    def update
      persist!(set_ivar(find_record))
    end

    def delete
      record = set_ivar(find_record)
      @cancel_url = redirect_for(record)
      render :template => 'islay/admin/shared/delete'
    end

    def destroy
      record = resource_class[:class].find(params[:id])
      record.destroy
      redirect_to destroy_redirect_for(record)
    end

    private

    def persist!(record)
      if record.update_attributes(params[resource_class[:name]])
        redirect_to(redirect_for(record))
      else
        dependencies
        invalid_record
        render(record.new_record? ? :new : :edit)
      end
    end

    def redirect_for(record)
      url_for([:admin, record])
    end

    def destroy_redirect_for(record)
      url_for([:admin, record])
    end

    # This is intended to be over-ridden by any controllers using this mixin.
    # The idea being that they can add custom logic for handling errors.
    def invalid_record

    end

    # Can be over-ridden in subclasses to provide the data needed when
    # rendering a form.
    def dependencies

    end

    def find_record
      resource_class[:class].find(params[:id])
    end

    def new_record
      resource_class[:class].new
    end

    def set_ivar(record)
      instance_variable_set("@#{resource_class[:name]}", record)
    end

    def find_parent
      parent = resource_parent[:class].find(params[resource_parent[:param]])
      instance_variable_set("@#{resource_parent[:name]}", parent)
    end
  end
end
