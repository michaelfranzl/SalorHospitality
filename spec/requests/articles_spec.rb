require 'spec_helper'

describe "Articles" do
  def log_in(user)
    visit new_session_path
    fill_in "password", :with => user.password
    click_button "Login"
  end

  describe "GET /articles/new" do
    it "denies permission for user belonging to another company" do
      article_company_0 = Factory :article000
      user_company_1 = Factory :user100
      log_in(user_company_1)
      visit edit_article_path(article_company_0)
      #save_and_open_page
      page.should have_content(I18n.t('sessions.permission_denied.permission_denied'))
    end
  end
end
