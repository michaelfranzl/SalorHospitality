class AddFieldsToUser < ActiveRecord::Migration
  def self.up
    add_column(:users, :current_company_id, :integer)
    add_column(:users, :is_owner, :boolean, :default => false)
    add_column(:users, :owner_id, :integer)
  end

  def self.down
    remove_column(:users, :current_company_id)
    remove_column(:users, :is_owner)
    remove_column(:users, :owner_id)
  end
end
