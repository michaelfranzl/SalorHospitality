class AddTaxNumberToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :tax_info, :string
  end
end
