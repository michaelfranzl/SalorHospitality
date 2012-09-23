class CreateCustomers < ActiveRecord::Migration
  def self.up
    create_table :customers do |t|
      t.string :first_name
      t.string :last_name
      t.string :company_name
      t.text :address
      t.string :city
      t.string :state
      t.string :postalcode
      t.string :m_number
      t.string :m_points
      t.string :email
      t.string :telephone
      t.string :cellphone

      t.timestamps
    end
  end

  def self.down
    drop_table :customers
  end
end
