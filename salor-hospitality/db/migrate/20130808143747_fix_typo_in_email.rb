class FixTypoInEmail < ActiveRecord::Migration
  def up
    rename_column :emails, :receiptient, :receipient
  end

  def down
  end
end
