class AddTaxSumToSurchargeItem < ActiveRecord::Migration
  def change
    add_column :surcharge_items, :tax_sum, :float
  end
end
