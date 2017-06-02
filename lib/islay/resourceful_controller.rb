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
      render :layout => !request.xhr?
    end

    def create
      persist!(set_ivar(new_record))
    end

    def edit
      set_ivar(find_record)
      dependencies
      render :layout => !request.xhr?
    end

    def update
      persist!(set_ivar(find_record))
    end

    def update_position
      ids, meth = case params[:do]
      when 'move_up'   then [params[:ids], :move_higher]
      when 'move_down' then [params[:ids].reverse, :move_lower]
      end

      klass = resource_class[:class]
      ids.each {|id| klass.find(id).send(meth)}

      flash[:ids] = params[:ids]

      bounce_back
    end

    def delete
      @resource = if resource_parent
        [:admin, find_parent, find_record]
      else
        find_record
      end

      @cancel_url = redirect_for(@resource)
      render :template => 'islay/admin/shared/delete', :layout => !request.xhr?
    end

    def destroy
      record = find_record
      record.destroy
      redirect_to destroy_redirect_for(record)
    end

    private

    def persist!(record)
      if record.update_attributes(params[resource_class[:name]].permit!)
        redirect_to(redirect_for(record))
      else
        dependencies
        invalid_record
        render(record.new_record? ? :new : :edit)
      end
    end

    def redirect_for(record)
      path(record)
    end

    def destroy_redirect_for(record)
      path(resource_class[:plural].to_sym)
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
