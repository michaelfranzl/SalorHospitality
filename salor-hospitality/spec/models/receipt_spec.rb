require 'rails_helper'

describe Receipt do
  context "content" do
    it "accepts null byte in content" do
      expect { Receipt.new(content:"\e@\e!8\n\n\n\n\n21:12:23      #     5\nSuperuser 0      T000\n—————————————————————\n  1 Article0050      \n\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4      16,00\n\n\n\n\n\n\n\u001DV\u0000") }.not_to raise_error
    end
  end
end
