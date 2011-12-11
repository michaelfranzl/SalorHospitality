class CashRegister < ActiveRecord::Base
  belongs_to :company
  belongs_to :vendor
end
