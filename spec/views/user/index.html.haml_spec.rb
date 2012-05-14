require 'spec_helper'

describe "users/index.html.haml" do
  it "has a h2" do
    view.stub(:new_user_path).and_return('abc')
    view.stub(:edit_user_path).and_return('abc')
    view.stub(:user_path).and_return('abc')
    assign(:users, [Factory(:user)])
    render
    rendered.should have_selector('h2')
  end
end
