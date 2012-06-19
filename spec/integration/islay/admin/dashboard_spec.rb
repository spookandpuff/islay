require 'spec_helper'

describe Islay::Admin::DashboardController do
  before do
    @user = User.make!
  end

  it 'direct user to dashbaord' do
    visit('/admin/login')
    within('#new_user') do
      fill_in('user[email]', :with => @user.email)
      click_button('Sign in')
      fill_in('user[password]', :with => 'password')
    end
    page.should have_selector('.column.count-3 > p')
  end
end
