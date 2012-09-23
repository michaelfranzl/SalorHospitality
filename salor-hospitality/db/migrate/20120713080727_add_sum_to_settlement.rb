class AddSumToSettlement < ActiveRecord::Migration
  def change
    add_column :settlements, :sum, :float
  end
end
