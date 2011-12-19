require 'spec_helper'

describe "Session Requests" do

  def log_in(user)
    visit new_session_path
    fill_in "password", :with => user.password
    click_button "Login"
  end

  describe "GET /session/new" do
    it "displays the login page" do
      visit new_session_path
      page.should have_content('password')
    end

    it "logs a user in" do
      user = Factory :user
      log_in(user)
      #save_and_open_page
      page.should have_content(I18n.t('messages.hello_username', :name => user.login))
    end
  end
end
