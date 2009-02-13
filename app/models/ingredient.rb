class Ingredient < ActiveRecord::Base
  belongs_to :article
  validates_presence_of :amount, :stock_id
end
