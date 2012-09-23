class AddCompanyIdToModels < ActiveRecord::Migration
  def up
    add_column :customers, :company_id, :integer
    add_column :images, :company_id, :integer
    add_column :ingredients, :company_id, :integer
    add_column :logins, :company_id, :integer
    add_column :pages, :company_id, :integer
    add_column :partials, :company_id, :integer
    add_column :presentations, :company_id, :integer
  end

  def down
    remove_column :customers, :company_id
    remove_column :images, :company_id
    remove_column :ingredients, :company_id
    remove_column :logins, :company_id
    remove_column :pages, :company_id
    remove_column :partials, :company_id
    remove_column :presentations, :company_id
  end
end
