class Ingredient < ActiveRecord::Base
  belongs_to :article
  belongs_to :stock
  validates_presence_of :amount, :stock_id
  validates_numericality_of :amount
end
