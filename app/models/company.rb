class Company < ActiveRecord::Base
  belongs_to :user
  has_many :vendor_printers
  has_many :categories
  has_many :taxes, :class_name => "Tax"
  has_many :articles
  has_many :cost_centers
  has_many :tables
  serialize :unused_order_numbers

  accepts_nested_attributes_for :vendor_printers, :allow_destroy => true, :reject_if => proc { |attrs| attrs['name'] == '' }

  def logo=(data)
    write_attribute :content_type, data.content_type.chomp
    write_attribute :image, data.read
  end
end
