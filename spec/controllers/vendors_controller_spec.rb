require 'spec_helper'

# Stubbing a method is all about replacing the method with code that returns a specified result (or perhaps raises a specified exception). Mocking a method is all about asserting that a method has been called (perhaps with particular parameters).

describe VendorsController do

  #describe "#new" do
  #  it "returns http success" do 
  #    user = Factory :user
  #    session[:user_id] = user.id
  #    get 'new'
  #    #flash[:notice].should_not be
  #    response.should be_success  
  #  end

  #  #it "should pass params[:menu_item] to menu item" do
  #  #  post 'create', :menu_item => { :name => 'Plain' }
  #  #  assigns[:menu_item].name.should == 'Plain'
  #  #end
  #end

end
