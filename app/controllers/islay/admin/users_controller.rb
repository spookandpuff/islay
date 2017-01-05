module Islay
  module Admin
    class UsersController < ApplicationController
      resourceful :user
      header 'Users'
      nav_scope :config

      def index
        @users = User.page(params[:page]).filtered(params[:filter]).sorted(params[:sort])
      end

      private

      def redirect_for(model)
        path(:users)
      end
    end
  end
end
