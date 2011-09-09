class AddResFieldsToCompanies < ActiveRecord::Migration
  def self.up
    add_column :companies, :res_fetch_url, :string
    add_column :companies, :res_confirm_url, :string
  end

  def self.down
    remove_column :companies, :res_confirm_url
    remove_column :companies, :res_fetch_url
  end
end
