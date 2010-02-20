class Quantity < ActiveRecord::Base

  def price=(price)
    write_attribute(:price, price.gsub(',', '.'))
  end

  validates_presence_of :name, :article_id
  validates_numericality_of :price

end
