require 'spec_helper'

describe User do
  it "should be created" do
    User.should have(:no).records
    user = Factory :user
    User.should have(1).records
  end
end
