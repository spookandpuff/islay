require 'test_helper'

module Islay
  class Admin::DashboardControllerTest < ActionController::TestCase
    def setup
      @user = User.make!
    end

    test "user can log in and see dashboard" do
      visit('/admin/login')
      within('new_user') do
        fill_in('user[email]', :with => @user.email)
        click_button('Sign in')
        fill_in('user[password]', :with => 'password')
      end

      page.should have_selector('#header > h1')
    end
  end
end
