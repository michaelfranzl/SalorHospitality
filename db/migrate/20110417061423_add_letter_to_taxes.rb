class AddLetterToTaxes < ActiveRecord::Migration
  def self.up
    add_column :taxes, :letter, :string
  end

  def self.down
    remove_column :taxes, :letter
  end
end
