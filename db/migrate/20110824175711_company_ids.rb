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
    
     add_column(:groups, :company_id, :integer)
    add_index(:groups, :company_id, :name => "index_groups_company_id")
    
     add_column(:items, :company_id, :integer)
    add_index(:items, :company_id, :name => "index_items_company_id")
    
     add_column(:quantities, :company_id, :integer)
    add_index(:quantities, :company_id, :name => "index_quantities_company_id")
    
     add_column(:settlements, :company_id, :integer)
    add_index(:settlements, :company_id, :name => "index_settlements_company_id")
    

    add_column(:stocks, :company_id, :integer)
    add_index(:stocks, :company_id, :name => "index_stocks_company_id")
    
    add_column(:options, :company_id, :integer)
    add_index(:options, :company_id, :name => "index_options_company_id")
    
    
  end

  def self.down
  end
end
