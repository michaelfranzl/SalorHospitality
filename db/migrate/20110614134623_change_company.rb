class ChangeCompany < ActiveRecord::Migration
  def self.up
    add_column :companies, :time_offset, :integer, :default => 0
    add_column :companies, :mode, :string
    remove_column :companies, :saas
  end

  def self.down
    remove_column :companies, :time_offset
    remove_column :companies, :mode
    add_column :companies, :saas, :boolean
  end
end
