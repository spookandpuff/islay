class Islay::ApplicationCell < Cell::ViewModel
  # Include all the application helper methods and
  include Islay::ApplicationHelper

  # You need to include controller methods you where using from Rails explicitly.
  include AbstractController::Helpers
  include AbstractController::Translation
  # Look at https://github.com/rails/rails/tree/4-2-3/actionpack/lib/abstract_controller
  # if you need more.

  # If you want to access controller methods from your cell, you can hook that up like this
  delegate :current_user, :controller_name, :flash, :path, :render_path, to: :parent_controller
  helper_method :current_user
  helper_method :controller_name
  helper_method :path
  helper_method :flash

  # Cells 4 no longer uses action_name.
  # This workaround sets it whenever a state is called.
  attr_accessor :action_name

  def call(state=:show, *args)
   @action_name = state
   super
  end

  view_paths << "#{Islay::Engine.root}/app/cells"

end
