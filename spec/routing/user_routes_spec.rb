require "spec_helper"

describe "routes to the users controller" do
  it "routes a named route" do
    {:get => users_path}.
      should route_to('users#index')
  end

  it "routes /users to the users controller" do
    get("/users").
      should route_to("users#index")
  end

  it 'sets url helpers correctly' do
   users_path.should == '/users'
  end
end
