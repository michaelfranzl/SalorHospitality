class RenameUserCompanyId < ActiveRecord::Migration
  def up
    rename_column :users, :current_company_id, :company_id
  end

  def down
    rename_column :users, :company_id, :current_company_id
  end
end
