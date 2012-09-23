class AddCompanyIdToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :company_id, :integer
  end

  def self.down
    remove_column :users, :company_id
  end
end
