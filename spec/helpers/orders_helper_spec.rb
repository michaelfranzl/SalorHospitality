require 'spec_helper'

describe OrdersHelper do
  describe "#compose_item_label" do
    it "concatenates" do
      item = Factory(:item_from_quantity)
      helper.compose_item_label(item).should == "#{ item.quantity.prefix } #{ item.article.name } #{ item.quantity.postfix }"
    end
  end
end
