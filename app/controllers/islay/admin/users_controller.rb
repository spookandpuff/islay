module Islay
  module Admin
    class UsersController < ApplicationController
      resourceful :user
      header 'Users'

      def index
        @users = User.order(:name)
      end

      private

      def redirect_for(model)
        path(:users)
      end
    end
  end
end
