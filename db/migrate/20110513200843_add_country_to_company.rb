class AddCountryToCompany < ActiveRecord::Migration
  def self.up
    add_column :companies, :country, :string
  end

  def self.down
    remove_column :companies, :country
  end
end
