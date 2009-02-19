class Item < ActiveRecord::Base
  belongs_to :order
  belongs_to :article
  validates_presence_of :count, :article_id
end
