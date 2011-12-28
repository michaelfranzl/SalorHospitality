require 'spec_helper'

describe "Category Requests" do
  def set_up_models
    @company = Factory :company
    @vendor = Factory :vendor, :company => @company
    @user = Factory :user, :company => @company, :vendors => [@vendor]
    @category = Factory :category,:name => "Category1234", :company => @company, :vendor => @vendor
    @tax = Factory :tax, :company => @company, :vendor => @vendor
  end 
  def log_in(user)
    #visit new_session_path
    visit "/session/request_specs_login?password=xxx"
  end
    context "CRUD Operations" do
      it "displays an index" do
        set_up_models
        log_in @user
        visit categories_path
        page.should have_content("Category1234")
      end # shows the index page
      context "when editing a category" do
        it "allows you to edit a category" do
          set_up_models
          log_in @user
          
          visit edit_category_path @category
          
          fill_in "category_name", :with => "Category1234Edited"
          click_button I18n.t(:edit)
          
          page.should have_content I18n.t("categories.update.success")
          
        end # allows you to edit a category
        it "does not allow you to edit a category that does not belong to you" do
          company0 = Factory :company
          company1 = Factory :company
          vendor = Factory :vendor, :company => company0
          category = Factory :category,:name => "Category1234", :company => company0, :vendor => @vendor
          user = Factory :user, :company => company1
          log_in user
          visit edit_category_path(category)
          page.should have_content I18n.t('sessions.permission_denied.permission_denied')
        end # does not allow you to edit a non-existent categor
      end
      context "when creating a category", :focus => true do
        it "allows you to create a category" do
          set_up_models
          log_in @user
          visit new_category_path
          fill_in "category_name", :with => "Newly Created Category"
          select "10%", :from => "category_tax_id" 
          click_button I18n.t("create")
          page.should have_content(I18n.t("categories.create.success"))
        end # allows you to create a category
      end # when creating a category
    end
end
