require 'rails_helper'
describe Season do
  context "#current" do
    before(:each) do
      %w{spring summer autumn winter}.each do |season|
        FactoryGirl.create(:season,season.to_sym)
      end
    end
    context "autumn" do
      it "returns autumn" do
        travel_to Chronic.parse("2014-10-21") do
          expect(Season.current(Vendor.new(id:1)).name).to eq("Autumn")
        end
      end
      it "returns autumn for start date" do
        travel_to Chronic.parse("2014-09-20") do
          expect(Season.current(Vendor.new(id:1)).name).to eq("Autumn")
        end
      end
      it "returns autumn for end date" do
        travel_to Chronic.parse("2014-12-20") do
          expect(Season.current(Vendor.new(id:1)).name).to eq("Autumn")
        end
      end
    end
    context "winter" do
      it "returns Winter for start date" do
        travel_to Chronic.parse("2014-12-21") do
          expect(Season.current(Vendor.new(id:1)).name).to eq("Winter")
        end
      end
      it "returns Winter for end date" do
        travel_to Chronic.parse("2015-03-20") do
          expect(Season.current(Vendor.new(id:1)).name).to eq("Winter")
        end
      end

    end
  end
end
