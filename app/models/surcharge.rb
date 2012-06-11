class Surcharge < ActiveRecord::Base
  include Scope
  belongs_to :vendor
  belongs_to :company
  belongs_to :season
  belongs_to :guest_type
  has_many :surcharge_items
  has_many :taxes, :through => :tax_amounts
  has_many :tax_amounts

  serialize :taxes

  accepts_nested_attributes_for :tax_amounts, :allow_destroy => true, :reject_if => proc { |attrs| attrs['amount'] == '' }

  validates_presence_of :name, :season_id, :tax_amounts

  def calculate_totals
    amount = 0.0
    self.tax_amounts.each do |ta|
      amount += ta.amount
    end
    self.amount = amount
    self.save
  end
end
