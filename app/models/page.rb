class Page < ActiveRecord::Base
  has_and_belongs_to_many :partials
  
  scope :active, where(:active => true, :hidden => false)
  scope :existing, where('hidden=false or hidden is NULL')
  
  def image=(data)
    write_attribute :image_content_type, data.content_type.chomp
    write_attribute :image, data.read
  end
end
