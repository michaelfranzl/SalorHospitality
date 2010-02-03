class Settlement < ActiveRecord::Base
  belongs_to :user
  has_many :orders

  def price=(price)
    write_attribute(:revenue, price.gsub(',', '.'))
  end

  validates_presence_of :revenue
  validates_numericality_of :revenue
end
