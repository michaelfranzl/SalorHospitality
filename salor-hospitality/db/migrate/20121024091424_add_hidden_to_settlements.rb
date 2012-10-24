class AddHiddenToSettlements < ActiveRecord::Migration
  def change
    add_column :settlements, :hidden, :boolean
    add_column :settlements, :hidden_by, :integer
  end
end
