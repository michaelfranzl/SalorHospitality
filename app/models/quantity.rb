class Quantity < ActiveRecord::Base

  belongs_to :article

  def price=(price)
    write_attribute(:price, price.gsub(',', '.'))
  end

  validates_presence_of :name
  validates_presence_of :price
  validates_numericality_of :price

  def self.active_and_sorted
    find(:all, :conditions => 'active = 1 AND hidden = false', :order => 'name')
  end

end
