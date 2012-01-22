require 'spec_helper'

describe Category do
  before(:each) do
    @company = Factory :company
    @vendor = Factory :vendor, :company => @company
    @user = Factory :user, :company => @company, :vendors => [@vendor]
    @tax = Factory :tax, :company => @company, :vendor => @vendor
  end
  context "when creating a new category, " do
    it "should be valid" do
      @category = Factory :category
      @category.should be_valid
    end # should be valid
    it "should require a name" do
      @category = Factory :category
      @category.name = ''
      @category.should_not be_valid
    end # should require a name
    it "should require a tax" do
      @category = Factory :category
      @category.tax = nil
      @category.should_not be_valid
    end # should require a tax
  end
  
  context "when working with categories, " do
    it "should be sortable with an array of ids" do
      cat1 = Factory(:category, :name => "cat1", :company => @company, :vendor => @vendor, :tax => @tax)
      cat2 = Factory(:category, :name => "cat2", :company => @company, :vendor => @vendor, :tax => @tax)
      @categories = Category.accessible_by(@user)
      ofirst = @categories.first
      @categories = Category.sort(@categories,[@categories.last.id,@categories.first.id])
      @categories.first.position.should_not == ofirst.position
    end # multiple categories should be sortable
    it "should cast ids in passed array to_i when sorting" do
      cat1 = Factory(:category, :name => "cat1", :company => @company, :vendor => @vendor, :tax => @tax)
      cat2 = Factory(:category, :name => "cat2", :company => @company, :vendor => @vendor, :tax => @tax)
      @categories = Category.accessible_by(@user)
      ofirst = @categories.first
      @categories = Category.sort(@categories,[@categories.last.id.to_s,@categories.first.id.to_s])
      @categories.first.position.should_not == ofirst.position
    end # should cast ids in passed array to_i when sorting
    it "should not fail when a non-existent id is passed in the array" do
      cat1 = Factory(:category, :name => "cat1", :company => @company, :vendor => @vendor, :tax => @tax)
      cat2 = Factory(:category, :name => "cat2", :company => @company, :vendor => @vendor, :tax => @tax)
      @categories = Category.accessible_by(@user)
      ofirst = @categories.first
      @categories = Category.sort(@categories,[0,90890,@categories.last.id.to_s,@categories.first.id.to_s])
      @categories.first.position.should_not == ofirst.position
    end # should not fail when a non-existent id is passed in the array
  end
end
