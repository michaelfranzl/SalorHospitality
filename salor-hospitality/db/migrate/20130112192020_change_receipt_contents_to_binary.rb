class ChangeReceiptContentsToBinary < ActiveRecord::Migration
  def up
    change_column :receipts, :content, :binary, :limit => 5000
  end

  def down
    change_column :receipts, :content, :text
  end
end
