class AddHiddenAndActiveToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :hidden, :boolean, :default => false
    add_column :companies, :active, :boolean, :default => true
  end
end
