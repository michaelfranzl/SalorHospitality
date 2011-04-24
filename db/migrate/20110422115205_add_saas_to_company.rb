class AddSaasToCompany < ActiveRecord::Migration
  def self.up
    add_column :companies, :saas, :boolean, :default => false
  end

  def self.down
    remove_column :companies, :saas
  end
end
