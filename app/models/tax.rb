class Tax < ActiveRecord::Base
  has_many :categories

  validates_presence_of :name, :percent
  validates_numericality_of :percent

  def custom_name
    @custom_name = percent.to_s + '%, ' + name
  end
  
  def percent=(percent)
    write_attribute(:percent, percent.gsub(',', '.'))
  end

end
