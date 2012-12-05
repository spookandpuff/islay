class Islay::Public::ApplicationController < Islay::ApplicationController
  layout 'islay/public'

  helper_method :path

  private

  # A shortcut for generating routes namespaced to the Public module.
  #
  # @param [Symbol, ActiveRecord::Base, Hash] args
  #
  # @return String
  def path(*args)
    render_path(:public, args)
  end
end
