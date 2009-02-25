class Tax < ActiveRecord::Base
  has_many :categories

  validates_presence_of :name, :percent

  def custom_name
    @custom_name = percent.to_s + '%, ' + name
  end
end
