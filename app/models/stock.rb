class Stock < ActiveRecord::Base
  belongs_to :group

  def custom_name
    @custom_name = unit + ' ' + name
  end
end
