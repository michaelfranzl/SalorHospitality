require 'spec_helper'

describe "Article Requests" do
  def log_in(user)
    #visit new_session_path
    visit "/session/request_specs_login?password=xxx"
  end

  def set_up_models
    @company = Factory :company
    @vendor = Factory :vendor, :company => @company
    @user = Factory :user, :company => @company, :vendors => [@vendor]
    @category = Factory :category, :company => @company, :vendor => @vendor
    @article = Factory :article, :company => @company, :category => @category
  end

  describe "#index" do
    it "shows the index page" do
      user = Factory :user
      log_in user
      visit articles_path
      #save_and_open_page
      page.should have_css 'h2'
    end
  end

  describe "#edit and #update" do
    context "when user belongs to another company than the article" do
      it "displays permission denied" do
        company0 = Factory :company
        company1 = Factory :company
        article = Factory :article, :company => company0
        user = Factory :user, :company => company1
        log_in user
        visit edit_article_path(article)
        page.should have_content I18n.t 'sessions.permission_denied.permission_denied'
      end
    end

    context "when logged in" do
      it "displays #edit form and updates the article successfully" do
        set_up_models
        log_in @user
        visit edit_article_path(@article)
        fill_in "article_name", :with => 'new name'
        click_button I18n.t :edit
        page.should have_content I18n.t 'articles.update.success'
      end
    end
  end

  describe "#new and #create" do
    it "fails submitting an empty form" do
      set_up_models
      log_in @user
      visit new_article_path
      click_button I18n.t :create
      page.should have_content "#{ Article.human_attribute_name(:name) } #{ I18n.t 'errors.messages.blank' }"
      page.should have_content "#{ Article.human_attribute_name(:category) } #{ I18n.t 'errors.messages.blank' }"
      page.should have_content "#{ Article.human_attribute_name(:price) } #{ I18n.t :must_be_entered_either_for_article_or_for_quantity }"
      page.should have_content "#{ Article.human_attribute_name(:price) } #{ I18n.t 'errors.messages.not_a_number' }"
      page.should have_content I18n.t 'articles.create.failure'
    end

    it "fails submitting an incomplete form consisting of variant with missing price", :js => true do
      set_up_models
      log_in @user
      #save_and_open_page
      visit new_article_path
      fill_in "article_name", :with => 'new name'
      fill_in "article_price", :with => 10
      click_link "add_quantity"
      find('#quantities_new').fill_in(I18n.t(Quantity.human_attribute_name(:name))) 
      click_button I18n.t :create
      page.should have_content I18n.t 'articles.create.success'
    end

    it "succeeds submitting an article without quantities" do
      set_up_models
      log_in @user
      visit new_article_path
      fill_in "article_name", :with => 'new name'
      fill_in "article_price", :with => 10
      select @category.name, :from => 'article_category_id'
      click_button I18n.t :create
      page.should have_content I18n.t 'articles.create.success'
    end
  end
end
