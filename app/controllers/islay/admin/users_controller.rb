module Islay
  module Admin
    class UsersController < ApplicationController
      resourceful :user
      header 'Users'
    end
  end
end
