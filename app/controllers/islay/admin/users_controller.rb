module Islay
  module Admin
    class UsersController < ApplicationController
      resourceful :user
      header 'Users'
      nav_scope :config

      before_action :check_password_update, only: [:update, :create]

      def index
        @users = User.page(params[:page]).filtered(params[:filter]).sorted(params[:sort])
      end

      private

      def redirect_for(model)
        path(:users)
      end

      # Remove the password params if they haven't been supplied -
      # This is to allow an optional password update
      def check_password_update
        if params[:user][:password].blank? and params[:user][:password_confirmation].blank?
          params[:user].extract!(:password, :password_confirmation)
        end
      end
    end
  end
end
