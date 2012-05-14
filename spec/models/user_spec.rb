require 'spec_helper'

describe User do
  before(:each) do
    #User.should have(:no).records
  end

  it "should be created" do
    user = Factory.create :user
    #User.should have(1).records
    #user.cash.should == 1220
    user.should be_valid
  end

  it "should be invalid without a password" do
    user = Factory.build :invalid_user
    user.should have(1).error_on(:password)
  end

  it "should warn the user without a password" do
    user = Factory.build :invalid_user
    user.error_on(:password).should include(I18n.t('errors.messages.blank'))
  end

  it "tests the stub method" do
    user = Factory.build :invalid_user
    user.stub(:valid?) { true }
    user.should be_valid
  end
end
