class TaxAmount < ActiveRecord::Base
  include Scope
  belongs_to :tax
  belongs_to :surcharge
  belongs_to :vendor
  belongs_to :company
end
