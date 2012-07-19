# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'spec_helper'

describe "Category Requests" do
  def set_up_models
    @company = Factory :company
    @vendor = Factory :vendor, :company => @company
    @user = Factory :user, :company => @company, :vendors => [@vendor]
    @tax = Factory :tax, :company => @company, :vendor => @vendor
    @category = Factory :category,:name => "Category1234", :company => @company, :vendor => @vendor, :tax => @tax
    
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
      it "allows you to sort categories on the index page" do
        set_up_models
      end # allows you to sort categories on the index page
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
      context "when creating a category" do
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
