class Company < ActiveRecord::Base
  belongs_to :user
  has_many :vendor_printers
  has_many :categories
  has_many :taxes, :class_name => "Tax"
  has_many :articles
  has_many :cost_centers
  has_many :tables
  has_many :images, :as => :imageable
  serialize :unused_order_numbers
  include ImageMethods

  accepts_nested_attributes_for :vendor_printers, :allow_destroy => true, :reject_if => proc { |attrs| attrs['name'] == '' }

  accepts_nested_attributes_for :images, :allow_destroy => true, :reject_if => :all_blank

  def image
    return self.images.first.image unless Image.count(:conditions => "imageable_id = #{self.id}") == 0
    "/images/client_logo.png"
  end

end
