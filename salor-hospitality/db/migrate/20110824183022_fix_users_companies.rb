class FixUsersCompanies < ActiveRecord::Migration
  def self.up
    add_column(:companies,:user_id, :integer)
    add_index(:companies,:user_id, :name => "index_company_user_id")
    
    remove_column(:users, :company_id)
  end

  def self.down
  end
end
