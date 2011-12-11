class CashDrawer < ActiveRecord::Base
  belongs_to :company
  belongs_to :vendor
  belongs_to :user
end
