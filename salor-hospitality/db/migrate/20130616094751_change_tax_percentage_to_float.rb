class ChangeTaxPercentageToFloat < ActiveRecord::Migration
  def up
    change_column :taxes, :percent, :float
  end

  def down
    change_column :taxes, :percent, :integer
  end
end
