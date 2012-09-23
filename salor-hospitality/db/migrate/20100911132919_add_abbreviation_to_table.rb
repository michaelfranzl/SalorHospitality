class AddAbbreviationToTable < ActiveRecord::Migration
  def self.up
    add_column :tables, :abbreviation, :string
  end

  def self.down
    remove_column :tables, :abbreviation
  end
end
