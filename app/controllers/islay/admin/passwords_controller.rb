module Islay
  module Admin
    class PasswordsController < Devise::PasswordsController
      layout 'islay/login'
    end
  end
end
