class AddModels < ActiveRecord::Migration
  def up
    create_table :companies do |t|
      t.string  :name
    end
    create_table :cash_registers do |t|
      t.string  :name
      t.integer :vendor_id
      t.integer :company_id
    end
    create_table :cash_drawers do |t|
      t.string  :name
      t.integer :user_id
      t.integer :vendor_id
      t.integer :company_id
    end
  end

  def down
    drop_table :companies
    drop_table :cash_registers
    drop_table :cash_drawers
  end
end
