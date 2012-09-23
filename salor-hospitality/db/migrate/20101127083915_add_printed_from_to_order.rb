class AddPrintedFromToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :printed_from, :string
  end

  def self.down
    remove_column :orders, :printed_from
  end
end
