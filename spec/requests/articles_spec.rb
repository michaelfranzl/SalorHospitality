require 'spec_helper'

describe "Article Requests" do
  def log_in(user)
    visit "/session/request_specs_login?password=xxx"
  end

  def set_up_models
    @company = Factory :company
    @vendor = Factory :vendor, :company => @company
    @user = Factory :user, :company => @company, :vendors => [@vendor]
    @category = Factory :category, :company => @company, :vendor => @vendor
    @article = Factory :article, :company => @company, :vendor => @vendor, :category => @category, :name => 'Article 1'
    @article2 = Factory :article, :company => @company, :vendor => @vendor, :category => @category, :name => 'Article 2'
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
    context "foreign user tries to access" do
      it "displays not found" do
        company0 = Factory :company
        company1 = Factory :company
        article = Factory :article, :company => company0
        user = Factory :user, :company => company1
        log_in user
        visit edit_article_path(article)
        page.should have_content I18n.t ':not_found'
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

      it "displays #edit form and fails to update" do
        set_up_models
        log_in @user
        visit edit_article_path(@article)
        fill_in "article_name", :with => ''
        click_button I18n.t :edit
        page.should have_content I18n.t 'articles.update.failure'
      end
    end
  end

  describe "#new and #create" do
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

    it "succeeds submitting an article with quantities", :js => true do
      set_up_models
      log_in @user
      visit new_article_path
      fill_in "article_name", :with => 'new name'
      fill_in "article_price", :with => 10
      find('#add_quantity').click
      select @category.name, :from => 'article_category_id'
      find('.prefix').set('Prefix')
      find('.price').set('20')
      click_button I18n.t :create
      page.should have_content I18n.t 'articles.create.success'
    end

    it "fails submitting an empty form" do
      set_up_models
      log_in @user
      visit new_article_path
      click_button I18n.t :create
      page.should have_content I18n.t 'articles.create.failure'
    end

    it "fails submitting an incomplete form consisting of variant with missing price", :js => true do
      set_up_models
      log_in @user
      visit new_article_path
      fill_in "article_name", :with => 'new name'
      fill_in "article_price", :with => 10
      find('#add_quantity').click
      select @category.name, :from => 'article_category_id'
      find('.prefix').set('Prefix')
      click_button I18n.t :create
      page.should have_content I18n.t 'articles.create.failure'
    end
  end

  describe "#destroy" do
    it "destroys an article" do
      set_up_models
      log_in @user
      visit edit_article_path(@article)
      find('.delete').click
      page.should have_content I18n.t 'articles.destroy.success'
    end
  end

  describe "#active" do
    it "shows the page" do
      set_up_models
      log_in @user
      visit '/articles/active'
      page.should have_content I18n.t 'scope_names.active'
    end
  end

  describe "#waiterpad" do
    it "shows the page" do
      set_up_models
      log_in @user
      visit '/articles/waiterpad'
      page.should have_css 'table.waiterpad'
    end
  end

  describe "#update_cache" do
    it "updates the cache successfully" do
      set_up_models
      log_in @user
      visit '/articles/update_cache'
      page.should have_content I18n.t 'articles.cache_successfully_updated'
    end
  end

  describe "#index" do
    it "shows the index page" do
      set_up_models
      log_in @user
      visit articles_path
      page.should have_css 'table.articles'
    end
    it "downloads articles.js" do
      set_up_models
      log_in @user
      visit '/articles.js'
      page.response_headers['Content-Type'].should == "text/javascript"
    end
  end

  describe "#listall" do
    it "displays the page" do
      set_up_models
      log_in @user
      visit '/articles/listall'
      page.should have_css 'div.articles_listall'
    end
  end

  describe "#find" do
    it "returns search results", :js => true do
      set_up_models
      log_in @user
      visit articles_path
      fill_in "article_name", :with => 'article'
      page.should have_css 'li.search_result'
    end
  end

  describe "#sort_index" do
    it "displays the page" do
      set_up_models
      log_in @user
      visit '/articles/sort_index'
      page.should have_content I18n.t 'articles.sort_index.sort'
    end
  end

  describe "#change_scope" do
    it "adds waiterpad scope to an active article", :js => true do
      set_up_models
      log_in @user
      visit articles_path
      source = page.find "#active_#{ @article2.id }"
      target = page.find "#add_to_waiterpad"
      source.drag_to target
      page.should have_css "td#add_to_active li#active_#{ @article2.id }"
    end

    it "removes active scope", :js => true do
      set_up_models
      log_in @user
      visit articles_path
      source = page.find "#active_#{ @article2.id }"
      target = page.find "#remove"
      source.drag_to target
      page.should_not have_css "td#add_to_active li#active_#{ @article2.id }"
    end
  end


end
