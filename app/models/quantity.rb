class Quantity < ActiveRecord::Base

  belongs_to :article

  def price=(price)
    write_attribute(:price, price.gsub(',', '.'))
  end

  validates_presence_of :name
  validates_numericality_of :price

end
