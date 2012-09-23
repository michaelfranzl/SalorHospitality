class AddCountryToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :country, :string
  end
end
