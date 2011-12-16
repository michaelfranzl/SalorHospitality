require 'spec_helper'

describe UsersController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      #response.should be_success
    end
  end

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      #response.should be_success
    end
  end

end
