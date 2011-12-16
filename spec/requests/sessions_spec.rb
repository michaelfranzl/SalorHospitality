require 'spec_helper'

describe "Sessions" do
  describe "GET /session/new" do
    it "displays the login page" do
      visit new_session_path
      page.should have_content('password')
    end

    it "logs a user in" do
      user = Factory :user
      visit new_session_path

      fill_in "password", :with => user.password
      #save_and_open_page
      click_button "Login"

      page.should have_content(I18n.t('messages.hello_username', :name => user.login))
    end
  end
end
