class SurchargeItem < ActiveRecord::Base
  include Scope
  belongs_to :vendor
  belongs_to :company
  belongs_to :surcharge
  belongs_to :booking_item
  belongs_to :booking

  serialize :taxes

  def calculate_totals
    self.taxes = {}
    self.surcharge.tax_amounts.each do |ta|
      tax_object = ta.tax
      tax_sum = (ta.amount * ( tax_object.percent / 100.0 )).round(2)
      gro = (ta.amount).round(2)
      net = (gro - tax_sum).round(2)
      self.taxes[tax_object.id] = {:percent => tax_object.percent, :tax => tax_sum, :gro => gro, :net => net, :letter => tax_object.letter, :name => tax_object.name }
    end
  end
end
