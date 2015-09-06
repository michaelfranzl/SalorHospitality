class AddTpeToTax < ActiveRecord::Migration
  def change
    add_column :taxes, :tpe, :string
  end
end
