class AddScreenlockTimeoutToCompanies < ActiveRecord::Migration
  def self.up
    add_column :companies, :timeout, :integer, :default => -1
  end

  def self.down
    remove_column :companies, :timeout
  end
end
