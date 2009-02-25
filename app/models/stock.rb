class Stock < ActiveRecord::Base
  belongs_to :group

  validates_presence_of :name, :balance, :unit

  def custom_name
    @custom_name = unit + ' ' + name
  end
end
