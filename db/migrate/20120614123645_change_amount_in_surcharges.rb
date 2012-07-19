class ChangeAmountInSurcharges < ActiveRecord::Migration
  def up
    change_column :surcharges, :amount, :float, :default => 0
  end

  def down
  end
end
