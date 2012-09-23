class AddBankAccountToCompany < ActiveRecord::Migration
  def self.up
    add_column :companies, :bank_account1, :string
    add_column :companies, :bank_account2, :string
  end

  def self.down
    remove_column :companies, :bank_account2
    remove_column :companies, :bank_account1
  end
end
