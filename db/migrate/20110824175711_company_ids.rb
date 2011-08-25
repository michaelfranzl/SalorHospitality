class CompanyIds < ActiveRecord::Migration
  def self.up
    add_column(:articles,:company_id, :integer)
    add_index(:articles, :company_id, :name => "index_articles_company_id")
    
    add_column(:categories,:company_id, :integer)
    add_index(:categories,:company_id, :name => "index_categories_company_id")
    
    add_column(:cost_centers,:company_id, :integer)
    add_index(:cost_centers, :company_id, :name => "index_cost_centers_company_id")
    
    add_column(:orders, :company_id, :integer)
    add_index(:orders, :company_id, :name => "index_orders_company_id")
    
    add_column(:roles, :company_id, :integer)
    add_index(:roles, :company_id, :name => "index_roles_company_id")
    
    add_column(:tables, :company_id, :integer)
    add_index(:tables, :company_id, :name => "index_tables_company_id")
    
    add_column(:taxes, :company_id, :integer)
    add_index(:taxes, :company_id, :name => "index_taxes_company_id")
  end

  def self.down
  end
end
