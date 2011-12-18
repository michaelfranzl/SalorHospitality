require 'spec_helper'

describe Vendor do

  # it { should accept_values_for(:email, 'abc') }
  it "should be created" do
    vendor = Factory.create :vendor
    #vendor.name = nil
    vendor.should be_valid
  end
end
