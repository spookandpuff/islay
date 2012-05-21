module Islay
  module Admin
    class UsersController < ApplicationController
      resourceful :user
      header 'Users'

      private

      def redirect_for(model)
        path(:users)
      end
    end
  end
end
