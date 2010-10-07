class Quantity < ActiveRecord::Base

  belongs_to :article
  has_many :items

  default_scope :conditions => { :hidden => false }

  def price=(price)
    write_attribute(:price, price.gsub(',', '.'))
  end

  #validates_presence_of :prefix
  validates_presence_of :price
  validates_numericality_of :price

  def self.active_and_sorted
    find(:all, :conditions => 'active = 1 AND hidden = false', :order => 'prefix')
  end

end
